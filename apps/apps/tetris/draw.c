// Tetris: rendering. See tetris.h.
//
// The screen is never cleared between frames: draw_game() overwrites every
// cell that can change, so only the cells that actually changed reach the
// terminal (the OS sends the difference between the frames).

#include "tetris.h"
#include "io.h"
#include "screen.h"
#include "terminal.h"

#define PANEL_WIDTH 14                     // width of the widest panel text
#define PREVIEW_TOP 10                     // panel row of the next piece preview

static const struct { u8 code; u32 unicode; } GLYPHS[] = {
    { SC_BLOCK,     0x1F7E9 },             // green square
    { SC_CORNER_TL, 0x256D },              // box drawing, rounded corners
    { SC_CORNER_TR, 0x256E },
    { SC_CORNER_BL, 0x2570 },
    { SC_CORNER_BR, 0x256F },
    { SC_HLINE,     0x2500 },
    { SC_VLINE,     0x2502 },
};

static void draw_at(u32 col, u32 row, const char* str) {
    set_cursor_pos(col, row);
    prints(str);
}

// printc() takes a char, while the glyph codes are above 127
static void put(u8 code) {
    printc((char) code);
}

static void draw_panel_line(u32 panel_row, const char* label, u32 value) {
    set_cursor_pos(PANEL_LEFT, BOARD_TOP + panel_row);
    prints(label);
    printnum(value);
}

static void draw_status_line(u32 line, const char* str) {
    set_cursor_pos(BOARD_LEFT, STATUS_TOP + line);
    for (u32 i = 0; i < PANEL_WIDTH + 8; i++) printc(' ');     // erase the old text
    if (str) draw_at(BOARD_LEFT, STATUS_TOP + line, str);
}

// Tells which glyph to show for the board cell (x, y): a settled block,
// the falling piece or an empty cell
static u8 cell_glyph(const Game* game, i32 x, i32 y) {
    if (game->board[y][x]) return SC_BLOCK;

    if (game->state != GAME_OVER) {
        const Piece* p = &game->current;
        i32 px = x - p->pos.x;
        i32 py = y - p->pos.y;
        if (px >= 0 && px < 4 && py >= 0 && py < 4 && piece_cell(p->type, p->rotation, px, py)) {
            return SC_BLOCK;
        }
    }
    return ' ';
}

static void draw_horizontal_border(u32 row, u8 left_corner, u8 right_corner) {
    set_cursor_pos(BOARD_LEFT, row);
    put(left_corner);
    for (u32 x = 0; x < BOARD_WIDTH; x++) put(SC_HLINE);
    put(right_corner);
}

void draw_init(void) {
    for (u32 i = 0; i < sizeof(GLYPHS) / sizeof(GLYPHS[0]); i++) {
        term_set_screencode(GLYPHS[i].code, GLYPHS[i].unicode);
    }
}

// Draws the parts that never change: the border and the panel labels
void draw_frame(void) {
    clear_screen();

    draw_horizontal_border(BOARD_TOP, SC_CORNER_TL, SC_CORNER_TR);
    for (u32 y = 0; y < BOARD_HEIGHT; y++) {
        set_cursor_pos(BOARD_LEFT, BOARD_TOP + 1 + y);
        put(SC_VLINE);
        set_cursor_pos(BOARD_LEFT + BOARD_WIDTH + 1, BOARD_TOP + 1 + y);
        put(SC_VLINE);
    }
    draw_horizontal_border(BOARD_TOP + BOARD_HEIGHT + 1, SC_CORNER_BL, SC_CORNER_BR);

    draw_at(PANEL_LEFT, BOARD_TOP, "=== TETRIS ===");
    draw_at(PANEL_LEFT, BOARD_TOP + PREVIEW_TOP - 2, "Next piece:");
}

// Draws everything that changes: the board, the stats, the next piece
// and the status message
void draw_game(const Game* game) {
    char row[BOARD_WIDTH + 1];
    for (i32 y = 0; y < BOARD_HEIGHT; y++) {
        for (i32 x = 0; x < BOARD_WIDTH; x++) {
            row[x] = (char) cell_glyph(game, x, y);
        }
        row[BOARD_WIDTH] = '\0';
        draw_at(BOARD_LEFT + 1, BOARD_TOP + 1 + y, row);
    }

    draw_panel_line(2, "Score: ", game->score);
    draw_panel_line(4, "Level: ", game->level);
    draw_panel_line(6, "Lines: ", game->lines);

    char preview[5];
    for (i32 y = 0; y < 4; y++) {
        for (i32 x = 0; x < 4; x++) {
            preview[x] = piece_cell(game->next, 0, x, y) ? (char) SC_BLOCK : ' ';
        }
        preview[4] = '\0';
        draw_at(PANEL_LEFT, BOARD_TOP + PREVIEW_TOP + y, preview);
    }

    switch (game->state) {
        case GAME_OVER:
            draw_status_line(0, "Game over!");
            draw_status_line(1, "Press 'r' to restart");
            draw_status_line(2, "or 'q' to quit");
            break;
        case PAUSED:
            draw_status_line(0, "=== PAUSED ===");
            draw_status_line(1, "Press 'p' to continue");
            draw_status_line(2, 0);
            break;
        case PLAYING:
            draw_status_line(0, 0);
            draw_status_line(1, 0);
            draw_status_line(2, 0);
            break;
    }
}
