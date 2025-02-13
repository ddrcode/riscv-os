#ifndef TETRIS_H
#define TETRIS_H

#include "io.h"
#include "screen.h"
#include "sys_utils.h"
#include "types.h"
#include "terminal.h"

// Game constants
#define BOARD_WIDTH 12
#define BOARD_HEIGHT 18
#define LEFT_MARGIN 4
#define RIGHT_MARGIN 4
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
extern const char PIECES[7][4][4][4];

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

#endif // TETRIS_H