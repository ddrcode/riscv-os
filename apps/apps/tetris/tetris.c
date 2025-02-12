#include "io.h"
#include "screen.h"
#include "sys_utils.h"
#include "types.h"
#include "terminal.h"

// Game constants
#define BOARD_WIDTH 12
#define BOARD_HEIGHT 18
#define LEFT_MARGIN 4
#define GAME_SPEED_INITIAL 400
#define GAME_SPEED_MIN 50
#define SPEED_INCREASE 30
#define LINES_PER_LEVEL 10
#define INPUT_CHECK_INTERVAL 50
#define SOFT_DROP_SPEED 50

// Display characters
#define CHAR_EMPTY ' '
#define CHAR_BLOCK '#'
#define CHAR_BORDER '|'
#define CHAR_BOTTOM '-'
#define CHAR_CORNER '+'
#define CHAR_TOP_LEFT_CORNER 'A'
#define CHAR_TOP_RIGHT_CORNER 'B'
#define CHAR_BOTTOM_LEFT_CORNER 'C'
#define CHAR_BOTTOM_RIGHT_CORNER 'D'

// Game states
typedef enum {
    PLAYING,
    PAUSED,
    GAME_OVER
} GameState;

// Piece rotation states (0-3 = 0°, 90°, 180°, 270°)
typedef enum {
    ROT_0,
    ROT_90,
    ROT_180,
    ROT_270
} Rotation;

// Piece types
typedef enum {
    I_PIECE,
    O_PIECE,
    T_PIECE,
    S_PIECE,
    Z_PIECE,
    J_PIECE,
    L_PIECE
} PieceType;

// Position structure
typedef struct {
    i32 x;
    i32 y;
} Position;

// Piece structure
typedef struct {
    PieceType type;
    Position pos;
    Rotation rotation;
} Piece;

// Game board structure
typedef struct {
    char board[BOARD_HEIGHT][BOARD_WIDTH];
    Piece current_piece;
    PieceType next_piece;
    u32 score;
    u32 level;
    u32 lines;
    GameState state;
    u32 speed;
} Game;

// Tetromino definitions (each piece in each rotation)
const char PIECES[7][4][4][4] = {
    // I Piece
    {
        {
            {0,0,0,0},
            {1,1,1,1},
            {0,0,0,0},
            {0,0,0,0}
        },
        {
            {0,0,1,0},
            {0,0,1,0},
            {0,0,1,0},
            {0,0,1,0}
        },
        {
            {0,0,0,0},
            {0,0,0,0},
            {1,1,1,1},
            {0,0,0,0}
        },
        {
            {0,1,0,0},
            {0,1,0,0},
            {0,1,0,0},
            {0,1,0,0}
        }
    },
    // O Piece
    {
        {
            {0,1,1,0},
            {0,1,1,0},
            {0,0,0,0},
            {0,0,0,0}
        },
        {
            {0,1,1,0},
            {0,1,1,0},
            {0,0,0,0},
            {0,0,0,0}
        },
        {
            {0,1,1,0},
            {0,1,1,0},
            {0,0,0,0},
            {0,0,0,0}
        },
        {
            {0,1,1,0},
            {0,1,1,0},
            {0,0,0,0},
            {0,0,0,0}
        }
    },
    // T Piece
    {
        {
            {0,1,0,0},
            {1,1,1,0},
            {0,0,0,0},
            {0,0,0,0}
        },
        {
            {0,1,0,0},
            {0,1,1,0},
            {0,1,0,0},
            {0,0,0,0}
        },
        {
            {0,0,0,0},
            {1,1,1,0},
            {0,1,0,0},
            {0,0,0,0}
        },
        {
            {0,1,0,0},
            {1,1,0,0},
            {0,1,0,0},
            {0,0,0,0}
        }
    },
    // S Piece
    {
        {
            {0,1,1,0},
            {1,1,0,0},
            {0,0,0,0},
            {0,0,0,0}
        },
        {
            {0,1,0,0},
            {0,1,1,0},
            {0,0,1,0},
            {0,0,0,0}
        },
        {
            {0,0,0,0},
            {0,1,1,0},
            {1,1,0,0},
            {0,0,0,0}
        },
        {
            {1,0,0,0},
            {1,1,0,0},
            {0,1,0,0},
            {0,0,0,0}
        }
    },
    // Z Piece
    {
        {
            {1,1,0,0},
            {0,1,1,0},
            {0,0,0,0},
            {0,0,0,0}
        },
        {
            {0,0,1,0},
            {0,1,1,0},
            {0,1,0,0},
            {0,0,0,0}
        },
        {
            {0,0,0,0},
            {1,1,0,0},
            {0,1,1,0},
            {0,0,0,0}
        },
        {
            {0,1,0,0},
            {1,1,0,0},
            {1,0,0,0},
            {0,0,0,0}
        }
    },
    // J Piece
    {
        {
            {1,0,0,0},
            {1,1,1,0},
            {0,0,0,0},
            {0,0,0,0}
        },
        {
            {0,1,1,0},
            {0,1,0,0},
            {0,1,0,0},
            {0,0,0,0}
        },
        {
            {0,0,0,0},
            {1,1,1,0},
            {0,0,1,0},
            {0,0,0,0}
        },
        {
            {0,1,0,0},
            {0,1,0,0},
            {1,1,0,0},
            {0,0,0,0}
        }
    },
    // L Piece
    {
        {
            {0,0,1,0},
            {1,1,1,0},
            {0,0,0,0},
            {0,0,0,0}
        },
        {
            {0,1,0,0},
            {0,1,0,0},
            {0,1,1,0},
            {0,0,0,0}
        },
        {
            {0,0,0,0},
            {1,1,1,0},
            {1,0,0,0},
            {0,0,0,0}
        },
        {
            {1,1,0,0},
            {0,1,0,0},
            {0,1,0,0},
            {0,0,0,0}
        }
    }
};

// Function declarations
void init_game(Game* game);
void spawn_piece(Game* game);
bool check_collision(Game* game, Position pos, Rotation rot);
void merge_piece(Game* game);
void clear_lines(Game* game);
void draw_game(Game* game);
void update_game(Game* game);
void handle_input(Game* game);
PieceType random_piece(void);

// Initialize the game state
void init_game(Game* game) {
    term_set_screencode(CHAR_BLOCK, 0x2588); // Full block
    term_set_screencode(CHAR_BORDER, 0x2502); // Vertical line
    term_set_screencode(CHAR_BOTTOM, 0x2500); // Horizontal line
    term_set_screencode(CHAR_TOP_LEFT_CORNER, 0x256D); // Top left corner
    term_set_screencode(CHAR_TOP_RIGHT_CORNER, 0x256E); // Top right corner
    term_set_screencode(CHAR_BOTTOM_LEFT_CORNER, 0x2570); // Bottom left corner
    term_set_screencode(CHAR_BOTTOM_RIGHT_CORNER, 0x256F); // Bottom right corner

    // Clear the board
    for(i32 y = 0; y < BOARD_HEIGHT; y++) {
        for(i32 x = 0; x < BOARD_WIDTH; x++) {
            game->board[y][x] = CHAR_EMPTY;
        }
    }

    game->score = 0;
    game->level = 1;
    game->lines = 0;
    game->state = PLAYING;
    game->speed = GAME_SPEED_INITIAL;

    // Spawn first piece
    game->next_piece = random_piece();
    spawn_piece(game);
}

// Generate a random piece type
PieceType random_piece(void) {
    // Simple random number generation
    static u32 seed = 12345;
    seed = seed * 1103515245 + 12345;
    return (seed >> 16) % 7;
}

// Spawn a new piece at the top of the board
void spawn_piece(Game* game) {
    game->current_piece.type = game->next_piece;
    game->current_piece.pos.x = BOARD_WIDTH / 2 - 2;
    game->current_piece.pos.y = 0;
    game->current_piece.rotation = ROT_0;
    game->next_piece = random_piece();

    // Check if the new piece collides immediately (game over)
    if(check_collision(game, game->current_piece.pos, game->current_piece.rotation)) {
        game->state = GAME_OVER;
    }
}

// Check if a piece collides with the board or boundaries
bool check_collision(Game* game, Position pos, Rotation rot) {
    const char (*piece)[4] = PIECES[game->current_piece.type][rot];

    for(i32 y = 0; y < 4; y++) {
        for(i32 x = 0; x < 4; x++) {
            if(piece[y][x]) {
                i32 board_x = pos.x + x;
                i32 board_y = pos.y + y;

                // Check boundaries
                if(board_x < 0 || board_x >= BOARD_WIDTH ||
                   board_y < 0 || board_y >= BOARD_HEIGHT) {
                    return true;
                }

                // Check collision with existing blocks
                if(game->board[board_y][board_x] != CHAR_EMPTY) {
                    return true;
                }
            }
        }
    }
    return false;
}

// Merge the current piece into the board
void merge_piece(Game* game) {
    const char (*piece)[4] = PIECES[game->current_piece.type][game->current_piece.rotation];

    for(i32 y = 0; y < 4; y++) {
        for(i32 x = 0; x < 4; x++) {
            if(piece[y][x]) {
                i32 board_x = game->current_piece.pos.x + x;
                i32 board_y = game->current_piece.pos.y + y;
                game->board[board_y][board_x] = CHAR_BLOCK;
            }
        }
    }
}

// Clear completed lines and update score
void clear_lines(Game* game) {
    i32 lines_cleared = 0;

    for(i32 y = BOARD_HEIGHT - 1; y >= 0; y--) {
        bool line_complete = true;

        // Check if line is complete
        for(i32 x = 0; x < BOARD_WIDTH; x++) {
            if(game->board[y][x] == CHAR_EMPTY) {
                line_complete = false;
                break;
            }
        }

        if(line_complete) {
            lines_cleared++;

            // Move all lines above down
            for(i32 move_y = y; move_y > 0; move_y--) {
                for(i32 x = 0; x < BOARD_WIDTH; x++) {
                    game->board[move_y][x] = game->board[move_y - 1][x];
                }
            }

            // Clear top line
            for(i32 x = 0; x < BOARD_WIDTH; x++) {
                game->board[0][x] = CHAR_EMPTY;
            }

            y++; // Check the same line again as everything moved down
        }
    }

    if(lines_cleared > 0) {
        game->lines += lines_cleared;
        // More rewarding scoring system
        switch(lines_cleared) {
            case 1:
                game->score += 100 * game->level;
                break;
            case 2:
                game->score += 300 * game->level;
                break;
            case 3:
                game->score += 500 * game->level;
                break;
            case 4:
                game->score += 800 * game->level; // Tetris!
                break;
        }

        // Level up every LINES_PER_LEVEL lines
        u32 new_level = (game->lines / LINES_PER_LEVEL) + 1;
        if(new_level > game->level) {
            game->level = new_level;
            if(game->speed > GAME_SPEED_MIN) {
                game->speed -= SPEED_INCREASE;
            }
        }
    }
}

// Draw the entire game state
void draw_game(Game* game) {
    clear_screen();

    // Draw score and game information
    for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
    prints("=== TETRIS ===\n");

    for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
    prints("Score: ");
    printnum(game->score);
    printc('\n');

    for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
    prints("Level: ");
    printnum(game->level);
    printc('\n');

    for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
    prints("Lines: ");
    printnum(game->lines);
    printc('\n');

    for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
    prints("Speed: ");
    printnum((GAME_SPEED_INITIAL - game->speed) / SPEED_INCREASE + 1);
    printc('\n');

    // Draw top border
    for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
    printc(CHAR_TOP_LEFT_CORNER);
    for(i32 x = 0; x < BOARD_WIDTH; x++) printc(CHAR_BOTTOM);
    printc(CHAR_TOP_RIGHT_CORNER);
    printc('\n');

    // Draw board with side borders
    for(i32 y = 0; y < BOARD_HEIGHT; y++) {
        for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
        printc(CHAR_BORDER);

        for(i32 x = 0; x < BOARD_WIDTH; x++) {
            char cell = game->board[y][x];

            // Draw current piece
            if(cell == CHAR_EMPTY && game->state != GAME_OVER) {
                const char (*piece)[4] = PIECES[game->current_piece.type][game->current_piece.rotation];
                i32 piece_x = x - game->current_piece.pos.x;
                i32 piece_y = y - game->current_piece.pos.y;

                if(piece_x >= 0 && piece_x < 4 && piece_y >= 0 && piece_y < 4 && piece[piece_y][piece_x]) {
                    cell = CHAR_BLOCK;
                }
            }

            printc(cell);
        }

        printc(CHAR_BORDER);
        printc('\n');
    }

    // Draw bottom border
    for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
    printc(CHAR_BOTTOM_LEFT_CORNER);
    for(i32 x = 0; x < BOARD_WIDTH; x++) printc(CHAR_BOTTOM);
    printc(CHAR_BOTTOM_RIGHT_CORNER);
    printc('\n');

    // Draw next piece preview
    for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
    prints("Next piece:\n");
    const char (*next)[4] = PIECES[game->next_piece][ROT_0];
    for(i32 y = 0; y < 4; y++) {
        for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
        for(i32 x = 0; x < 4; x++) {
            printc(next[y][x] ? CHAR_BLOCK : ' ');
        }
        printc('\n');
    }

    if(game->state == GAME_OVER) {
        for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
        prints("Game Over!\n");
        for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
        prints("Final Score: ");
        printnum(game->score);
        printc('\n');
        for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
        prints("Press 'q' to exit...\n");
    } else if(game->state == PAUSED) {
        for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
        prints("=== PAUSED ===\n");
        for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
        prints("Press 'p' to continue\n");
    }
}

// Handle keyboard input
void handle_input(Game* game) {
    if(game->state == GAME_OVER) return;

    i32 ch = getc();
    if(ch == 0) return;

    if(ch == 'p') {
        game->state = (game->state == PLAYING) ? PAUSED : PLAYING;
        return;
    }

    if(game->state != PLAYING) return;

    Position new_pos = game->current_piece.pos;
    Rotation new_rot = game->current_piece.rotation;
    bool is_soft_drop = false;

    switch(ch) {
        case 'a': // Move left
            new_pos.x--;
            break;
        case 'd': // Move right
            new_pos.x++;
            break;
        case 's': // Move down
            new_pos.y++;
            is_soft_drop = true;
            break;
        case 'w': // Rotate
            new_rot = (new_rot + 1) % 4;
            break;
        case ' ': // Hard drop
            while(!check_collision(game, new_pos, new_rot)) {
                new_pos.y++;
            }
            new_pos.y--; // Move back up one step
            break;
    }

    // Apply movement if valid
    if(!check_collision(game, new_pos, new_rot)) {
        game->current_piece.pos = new_pos;
        game->current_piece.rotation = new_rot;
        // If it was a soft drop, update the timer to force immediate update
        if(is_soft_drop) {
            game->current_piece.pos.y++;
            if(check_collision(game, game->current_piece.pos, game->current_piece.rotation)) {
                game->current_piece.pos.y--;
                merge_piece(game);
                clear_lines(game);
                spawn_piece(game);
            }
        }
    }
}

// Update game state
void update_game(Game* game) {
    if(game->state != PLAYING) return;

    Position new_pos = game->current_piece.pos;
    new_pos.y++;

    if(check_collision(game, new_pos, game->current_piece.rotation)) {
        // Piece has landed
        merge_piece(game);
        clear_lines(game);
        spawn_piece(game);
    } else {
        // Move piece down
        game->current_piece.pos = new_pos;
    }
}

int main(void) {
    Game game;
    init_game(&game);
    term_hide_cursor();

    u32 time_since_input = 0;

    while(game.state != GAME_OVER) {
        draw_game(&game);

        // Check input more frequently than game updates
        while(time_since_input < game.speed && game.state != GAME_OVER) {
            handle_input(&game);
            sleep(INPUT_CHECK_INTERVAL);
            time_since_input += INPUT_CHECK_INTERVAL;
        }

        time_since_input = 0;
        if(game.state == PLAYING) {
            update_game(&game);
        }
    }

    // Final draw and wait for exit
    draw_game(&game);
    while(getc() != 'q');

    clear_screen();
    term_show_cursor();
    term_reset();
    return 0;
}
