#include "tetris.h"

// Tetromino definitions (each piece in each rotation)
const char PIECES[7][4][4][4] = {
    // I_PIECE
    {
        {
            {0, 0, 0, 0},
            {1, 1, 1, 1},
            {0, 0, 0, 0},
            {0, 0, 0, 0}
        },
        {
            {0, 1, 0, 0},
            {0, 1, 0, 0},
            {0, 1, 0, 0},
            {0, 1, 0, 0}
        },
        {
            {0, 0, 0, 0},
            {1, 1, 1, 1},
            {0, 0, 0, 0},
            {0, 0, 0, 0}
        },
        {
            {0, 1, 0, 0},
            {0, 1, 0, 0},
            {0, 1, 0, 0},
            {0, 1, 0, 0}
        }
    },
    // O_PIECE
    {
        {
            {0, 0, 0, 0},
            {0, 1, 1, 0},
            {0, 1, 1, 0},
            {0, 0, 0, 0}
        },
        {
            {0, 0, 0, 0},
            {0, 1, 1, 0},
            {0, 1, 1, 0},
            {0, 0, 0, 0}
        },
        {
            {0, 0, 0, 0},
            {0, 1, 1, 0},
            {0, 1, 1, 0},
            {0, 0, 0, 0}
        },
        {
            {0, 0, 0, 0},
            {0, 1, 1, 0},
            {0, 1, 1, 0},
            {0, 0, 0, 0}
        }
    },
    // T_PIECE
    {
        {
            {0, 0, 0, 0},
            {1, 1, 1, 0},
            {0, 1, 0, 0},
            {0, 0, 0, 0}
        },
        {
            {0, 1, 0, 0},
            {1, 1, 0, 0},
            {0, 1, 0, 0},
            {0, 0, 0, 0}
        },
        {
            {0, 1, 0, 0},
            {1, 1, 1, 0},
            {0, 0, 0, 0},
            {0, 0, 0, 0}
        },
        {
            {0, 1, 0, 0},
            {0, 1, 1, 0},
            {0, 1, 0, 0},
            {0, 0, 0, 0}
        }
    },
    // S_PIECE
    {
        {
            {0, 0, 0, 0},
            {0, 1, 1, 0},
            {1, 1, 0, 0},
            {0, 0, 0, 0}
        },
        {
            {1, 0, 0, 0},
            {1, 1, 0, 0},
            {0, 1, 0, 0},
            {0, 0, 0, 0}
        },
        {
            {0, 0, 0, 0},
            {0, 1, 1, 0},
            {1, 1, 0, 0},
            {0, 0, 0, 0}
        },
        {
            {1, 0, 0, 0},
            {1, 1, 0, 0},
            {0, 1, 0, 0},
            {0, 0, 0, 0}
        }
    },
    // Z_PIECE
    {
        {
            {0, 0, 0, 0},
            {1, 1, 0, 0},
            {0, 1, 1, 0},
            {0, 0, 0, 0}
        },
        {
            {0, 1, 0, 0},
            {1, 1, 0, 0},
            {1, 0, 0, 0},
            {0, 0, 0, 0}
        },
        {
            {0, 0, 0, 0},
            {1, 1, 0, 0},
            {0, 1, 1, 0},
            {0, 0, 0, 0}
        },
        {
            {0, 1, 0, 0},
            {1, 1, 0, 0},
            {1, 0, 0, 0},
            {0, 0, 0, 0}
        }
    },
    // J_PIECE
    {
        {
            {0, 0, 0, 0},
            {1, 1, 1, 0},
            {0, 0, 1, 0},
            {0, 0, 0, 0}
        },
        {
            {0, 1, 0, 0},
            {0, 1, 0, 0},
            {1, 1, 0, 0},
            {0, 0, 0, 0}
        },
        {
            {1, 0, 0, 0},
            {1, 1, 1, 0},
            {0, 0, 0, 0},
            {0, 0, 0, 0}
        },
        {
            {1, 1, 0, 0},
            {1, 0, 0, 0},
            {1, 0, 0, 0},
            {0, 0, 0, 0}
        }
    },
    // L_PIECE
    {
        {
            {0, 0, 0, 0},
            {1, 1, 1, 0},
            {1, 0, 0, 0},
            {0, 0, 0, 0}
        },
        {
            {1, 1, 0, 0},
            {0, 1, 0, 0},
            {0, 1, 0, 0},
            {0, 0, 0, 0}
        },
        {
            {0, 0, 1, 0},
            {1, 1, 1, 0},
            {0, 0, 0, 0},
            {0, 0, 0, 0}
        },
        {
            {0, 1, 0, 0},
            {0, 1, 0, 0},
            {0, 1, 1, 0},
            {0, 0, 0, 0}
        }
    }
};

// Initialize the game state
void init_game(Game* game) {
    term_set_screencode(CHAR_BLOCK, 0x1f7E9); // Full block
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