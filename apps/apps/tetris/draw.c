#include "tetris.h"
#include "io.h"

// Draw the entire game state
void draw_game(Game* game) {
    clear_screen();

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

        // Draw game information on the right side
        if (y == 0) {
            for(i32 i = 0; i < RIGHT_MARGIN; i++) printc(' ');
            prints("=== TETRIS ===");
        } else if (y == 2) {
            for(i32 i = 0; i < RIGHT_MARGIN; i++) printc(' ');
            prints("Score: ");
            printnum(game->score);
        } else if (y == 4) {
            for(i32 i = 0; i < RIGHT_MARGIN; i++) printc(' ');
            prints("Level: ");
            printnum(game->level);
        } else if (y == 6) {
            for(i32 i = 0; i < RIGHT_MARGIN; i++) printc(' ');
            prints("Lines: ");
            printnum(game->lines);
        } else if (y == 8) {
            for(i32 i = 0; i < RIGHT_MARGIN; i++) printc(' ');
            prints("Next piece:");
        } else if (y >= 10 && y < 14) {
            for(i32 i = 0; i < RIGHT_MARGIN; i++) printc(' ');
            const char (*next)[4] = PIECES[game->next_piece][ROT_0];
            for(i32 x = 0; x < 4; x++) {
                printc(next[y - 10][x] ? CHAR_BLOCK : ' ');
            }
        }

        printc('\n');
    }

    // Draw bottom border
    for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
    printc(CHAR_BOTTOM_LEFT_CORNER);
    for(i32 x = 0; x < BOARD_WIDTH; x++) printc(CHAR_BOTTOM);
    printc(CHAR_BOTTOM_RIGHT_CORNER);
    printc('\n');

    if(game->state == GAME_OVER) {
        for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
        println("Game Over!");
        for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
        prints("Final Score: ");
        printnum(game->score);
        println("");
        for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
        println("Press 'r' to restart");
        for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
        println("or 'q' to quit...");
    } else if(game->state == PAUSED) {
        for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
        println("=== PAUSED ===");
        for(i32 i = 0; i < LEFT_MARGIN; i++) printc(' ');
        println("Press 'p' to continue");
    }
}