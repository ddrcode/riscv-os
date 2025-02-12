#include "io.h"
#include "screen.h"
#include "sys_utils.h"
#include "types.h"
#include "terminal.h"

// Game constants
#define GAME_WIDTH 36
#define GAME_HEIGHT 20
#define MAX_SNAKE_LENGTH 100
#define INITIAL_SNAKE_LENGTH 4
#define GAME_SPEED 200  // ms between moves

// Game characters
#define SNAKE_HEAD '@'
#define SNAKE_BODY 'o'
#define FOOD '*'
#define BORDER_TOP_LEFT '+'
#define BORDER_TOP_RIGHT '+'
#define BORDER_BOTTOM_LEFT '+'
#define BORDER_BOTTOM_RIGHT '+'
#define BORDER_HORIZONTAL '-'
#define BORDER_VERTICAL ''

// Direction vectors
typedef enum {
    UP = 0,
    RIGHT = 1,
    DOWN = 2,
    LEFT = 3
} Direction;

// Snake segment structure
typedef struct {
    i32 x;
    i32 y;
} Point;

// Game state
typedef struct {
    Point snake[MAX_SNAKE_LENGTH];
    i32 length;
    Direction direction;
    Point food;
    u32 score;
    bool game_over;
} GameState;

// Function declarations
void init_game(GameState* game);
void draw_border(void);
void spawn_food(GameState* game);
void draw_game(GameState* game);
void update_game(GameState* game);
Direction get_input(Direction current);
bool check_collision(GameState* game);

// Initialize game state
void init_game(GameState* game) {
    game->length = INITIAL_SNAKE_LENGTH;
    game->direction = RIGHT;
    game->score = 0;
    game->game_over = false;

    // Initialize snake in the middle of the screen
    i32 start_x = GAME_WIDTH / 4;
    i32 start_y = GAME_HEIGHT / 2;

    for(i32 i = 0; i < game->length; i++) {
        game->snake[i].x = start_x - i;
        game->snake[i].y = start_y;
    }

    spawn_food(game);
}

// Draw game border
void draw_border(void) {
    // Top border
    set_cursor_pos(0, 1);
    printc(BORDER_TOP_LEFT);
    for(i32 i = 0; i < GAME_WIDTH; i++) printc(BORDER_HORIZONTAL);
    printc(BORDER_TOP_RIGHT);
    printc('\n');

    // Side borders
    for(i32 i = 0; i < GAME_HEIGHT; i++) {
        printc(BORDER_VERTICAL);
        set_cursor_pos(GAME_WIDTH + 1, i + 2);
        printc(BORDER_VERTICAL);
        printc('\n');
    }

    // Bottom border
    printc(BORDER_BOTTOM_LEFT);
    for(i32 i = 0; i < GAME_WIDTH; i++) printc(BORDER_HORIZONTAL);
    printc(BORDER_BOTTOM_RIGHT);
}

// Generate new food position
void spawn_food(GameState* game) {
    // Simple random position generation
    static u32 seed = 12345;
    seed = seed * 1103515245 + 12345;
    game->food.x = (seed >> 16) % (GAME_WIDTH - 2) + 1;
    seed = seed * 1103515245 + 12345;
    game->food.y = (seed >> 16) % (GAME_HEIGHT - 2) + 1;
}

// Draw the entire game state
void draw_game(GameState* game) {
    clear_screen();

    // Draw score on top
    prints("Score: ");
    printnum(game->score);
    printc('\n');

    draw_border();

    // Draw food
    set_cursor_pos(game->food.x, game->food.y + 1);
    printc(FOOD);

    // Draw snake
    for(i32 i = game->length - 1; i >= 0; i--) {
        set_cursor_pos(game->snake[i].x, game->snake[i].y + 1);
        printc(i == 0 ? SNAKE_HEAD : SNAKE_BODY);
    }

    // Draw game over message
    if(game->game_over) {
        set_cursor_pos(GAME_WIDTH/2 - 5, GAME_HEIGHT/2 + 1);
        prints("GAME OVER!");
    }
}

// Update game state
void update_game(GameState* game) {
    if(game->game_over) return;

    // Store previous head position
    Point prev = game->snake[0];

    // Move head
    switch(game->direction) {
        case UP:    game->snake[0].y--; break;
        case DOWN:  game->snake[0].y++; break;
        case LEFT:  game->snake[0].x--; break;
        case RIGHT: game->snake[0].x++; break;
    }

    // Check collisions
    if(check_collision(game)) {
        game->game_over = true;
        return;
    }

    // Check if food was eaten
    if(game->snake[0].x == game->food.x && game->snake[0].y == game->food.y) {
        // Move rest of snake before increasing length
        for(i32 i = game->length - 1; i > 0; i--) {
            game->snake[i] = game->snake[i-1];
        }
        game->snake[1] = prev;  // Put previous head position as first body segment
        game->length++;
        game->score += 10;
        spawn_food(game);
    } else {
        // Move rest of snake
        for(i32 i = game->length - 1; i > 0; i--) {
            game->snake[i] = game->snake[i-1];
        }
        game->snake[1] = prev;  // Put previous head position as first body segment
    }
}

// Get and process user input
Direction get_input(Direction current) {
    i32 ch = getc();

    if (ch == 0) {
        return current;
    }

    Direction new_dir = current;
    switch(ch) {
        case 'w': new_dir = (current != DOWN) ? UP : current; break;
        case 's': new_dir = (current != UP) ? DOWN : current; break;
        case 'a': new_dir = (current != RIGHT) ? LEFT : current; break;
        case 'd': new_dir = (current != LEFT) ? RIGHT : current; break;
    }

    return new_dir;
}

// Check for collisions with walls or self
bool check_collision(GameState* game) {
    Point head = game->snake[0];

    // Wall collision
    if(head.x <= 0 || head.x >= GAME_WIDTH + 1 ||
       head.y <= 0 || head.y >= GAME_HEIGHT + 1) {
        return true;
    }

    // Self collision
    for(i32 i = 1; i < game->length; i++) {
        if(head.x == game->snake[i].x && head.y == game->snake[i].y) {
            return true;
        }
    }

    return false;
}

int main(void) {
    GameState game;
    init_game(&game);
    term_hide_cursor();

    // Main game loop
    while(!game.game_over) {
        draw_game(&game);
        Direction new_dir = get_input(game.direction);
        game.direction = new_dir;
        update_game(&game);
        sleep(GAME_SPEED);
    }

    // Final draw and wait for input
    draw_game(&game);

    set_cursor_pos(GAME_WIDTH/2 - 12, GAME_HEIGHT/2 + 3);
    prints("Press any key to exit...");

    sleep(4000);
    while(!getc());

    clear_screen();
    term_show_cursor();

    return 0;
}
