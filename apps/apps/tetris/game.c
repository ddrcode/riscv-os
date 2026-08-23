// Tetris: pieces, rules and scoring. See tetris.h.

#include "tetris.h"
#include "time.h"

// Tetrominoes: [type][rotation][row]. Each row is a 4-bit picture of the
// piece's 4x4 box, the most significant bit being the leftmost cell.
static const u8 PIECES[PIECE_TYPES][4][4] = {
    [I_PIECE] = {
        { 0b0000, 0b1111, 0b0000, 0b0000 },
        { 0b0100, 0b0100, 0b0100, 0b0100 },
        { 0b0000, 0b1111, 0b0000, 0b0000 },
        { 0b0100, 0b0100, 0b0100, 0b0100 },
    },
    [O_PIECE] = {
        { 0b0000, 0b0110, 0b0110, 0b0000 },
        { 0b0000, 0b0110, 0b0110, 0b0000 },
        { 0b0000, 0b0110, 0b0110, 0b0000 },
        { 0b0000, 0b0110, 0b0110, 0b0000 },
    },
    [T_PIECE] = {
        { 0b0000, 0b1110, 0b0100, 0b0000 },
        { 0b0100, 0b1100, 0b0100, 0b0000 },
        { 0b0100, 0b1110, 0b0000, 0b0000 },
        { 0b0100, 0b0110, 0b0100, 0b0000 },
    },
    [S_PIECE] = {
        { 0b0000, 0b0110, 0b1100, 0b0000 },
        { 0b1000, 0b1100, 0b0100, 0b0000 },
        { 0b0000, 0b0110, 0b1100, 0b0000 },
        { 0b1000, 0b1100, 0b0100, 0b0000 },
    },
    [Z_PIECE] = {
        { 0b0000, 0b1100, 0b0110, 0b0000 },
        { 0b0100, 0b1100, 0b1000, 0b0000 },
        { 0b0000, 0b1100, 0b0110, 0b0000 },
        { 0b0100, 0b1100, 0b1000, 0b0000 },
    },
    [J_PIECE] = {
        { 0b0000, 0b1110, 0b0010, 0b0000 },
        { 0b0100, 0b0100, 0b1100, 0b0000 },
        { 0b1000, 0b1110, 0b0000, 0b0000 },
        { 0b1100, 0b1000, 0b1000, 0b0000 },
    },
    [L_PIECE] = {
        { 0b0000, 0b1110, 0b1000, 0b0000 },
        { 0b1100, 0b0100, 0b0100, 0b0000 },
        { 0b0010, 0b1110, 0b0000, 0b0000 },
        { 0b0100, 0b0100, 0b0110, 0b0000 },
    },
};

// Points for clearing 1, 2, 3 and 4 lines at once (multiplied by the level)
static const u32 LINE_POINTS[] = { 0, 100, 300, 500, 800 };


//----------------------------------------------------------------------------
// Random numbers (there is no RNG in the OS yet)

static u32 rng_state;

static void rng_init(void) {
    Result now = time_now();
    rng_state = now.err ? 0x2545F491 : now.val;   // fixed seed without an RTC
}

static PieceType random_piece(void) {
    rng_state = rng_state * 1103515245 + 12345;
    return (rng_state >> 16) % PIECE_TYPES;
}


//----------------------------------------------------------------------------

// Tells whether the cell (x, y) of the piece's 4x4 box is filled
bool piece_cell(PieceType type, Rotation rotation, i32 x, i32 y) {
    return (PIECES[type][rotation][y] >> (3 - x)) & 1;
}

// Checks whether the current piece fits the board at the given position
// and rotation (within the walls, not overlapping settled blocks)
bool game_fits(const Game* game, Position pos, Rotation rotation) {
    for (i32 y = 0; y < 4; y++) {
        for (i32 x = 0; x < 4; x++) {
            if (!piece_cell(game->current.type, rotation, x, y)) continue;
            i32 bx = pos.x + x;
            i32 by = pos.y + y;
            if (bx < 0 || bx >= BOARD_WIDTH || by < 0 || by >= BOARD_HEIGHT) return false;
            if (game->board[by][bx]) return false;
        }
    }
    return true;
}

static void spawn_piece(Game* game) {
    game->current.type = game->next;
    game->current.rotation = 0;
    game->current.pos.x = BOARD_WIDTH / 2 - 2;
    game->current.pos.y = 0;
    game->next = random_piece();
    game->since_fall = 0;

    if (!game_fits(game, game->current.pos, game->current.rotation)) {
        game->state = GAME_OVER;
    }
}

static void clear_board(Game* game) {
    for (i32 y = 0; y < BOARD_HEIGHT; y++) {
        for (i32 x = 0; x < BOARD_WIDTH; x++) {
            game->board[y][x] = false;
        }
    }
}

void game_init(Game* game) {
    rng_init();
    clear_board(game);
    game->score = 0;
    game->level = 1;
    game->lines = 0;
    game->fall_ms = FALL_INITIAL_MS;
    game->state = PLAYING;
    game->next = random_piece();
    spawn_piece(game);
}

// Removes complete lines, moving everything above them down.
// Returns the number of removed lines.
static u32 clear_lines(Game* game) {
    u32 cleared = 0;

    for (i32 y = BOARD_HEIGHT - 1; y >= 0; y--) {
        bool complete = true;
        for (i32 x = 0; x < BOARD_WIDTH && complete; x++) {
            complete = game->board[y][x];
        }
        if (!complete) continue;

        cleared++;
        for (i32 row = y; row > 0; row--) {
            for (i32 x = 0; x < BOARD_WIDTH; x++) {
                game->board[row][x] = game->board[row - 1][x];
            }
        }
        for (i32 x = 0; x < BOARD_WIDTH; x++) {
            game->board[0][x] = false;
        }
        y++;                               // the line moved down, check it again
    }

    return cleared;
}

// Makes the current piece part of the board and starts the next one
static void lock_piece(Game* game) {
    const Piece* p = &game->current;
    for (i32 y = 0; y < 4; y++) {
        for (i32 x = 0; x < 4; x++) {
            if (piece_cell(p->type, p->rotation, x, y)) {
                game->board[p->pos.y + y][p->pos.x + x] = true;
            }
        }
    }

    u32 cleared = clear_lines(game);
    if (cleared > 0) {
        game->lines += cleared;
        game->score += LINE_POINTS[cleared] * game->level;

        u32 level = game->lines / LINES_PER_LEVEL + 1;
        if (level > game->level) {
            game->level = level;
            u32 speedup = (level - 1) * FALL_SPEEDUP_MS;
            game->fall_ms = speedup < FALL_INITIAL_MS - FALL_MIN_MS
                          ? FALL_INITIAL_MS - speedup : FALL_MIN_MS;
        }
    }

    spawn_piece(game);
}

// Moves the current piece by (dx, dy) if it fits. Returns false otherwise.
bool game_try_move(Game* game, i32 dx, i32 dy) {
    Position pos = { game->current.pos.x + dx, game->current.pos.y + dy };
    if (!game_fits(game, pos, game->current.rotation)) return false;
    game->current.pos = pos;
    return true;
}

// Rotates the current piece clockwise if it fits. Returns false otherwise.
bool game_try_rotate(Game* game) {
    Rotation rotation = (game->current.rotation + 1) % 4;
    if (!game_fits(game, game->current.pos, rotation)) return false;
    game->current.rotation = rotation;
    return true;
}

// Moves the current piece one row down, or locks it if it can't move
void game_fall(Game* game) {
    game->since_fall = 0;
    if (!game_try_move(game, 0, 1)) {
        lock_piece(game);
    }
}

// Drops the current piece to the bottom and locks it
void game_drop(Game* game) {
    while (game_try_move(game, 0, 1)) {}
    lock_piece(game);
}

void game_toggle_pause(Game* game) {
    if (game->state == PLAYING) {
        game->state = PAUSED;
    } else if (game->state == PAUSED) {
        game->state = PLAYING;
    }
}
