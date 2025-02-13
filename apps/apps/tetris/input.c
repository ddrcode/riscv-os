#include "tetris.h"

// Handle keyboard input
void handle_input(Game* game) {
    if(game->state == GAME_OVER) return;

    i32 ch = getc();
    if(ch == 0) return;

    if(ch == 'p') {
        game->state = (game->state == PLAYING) ? PAUSED : PLAYING;
        return;
    }

    if(ch == 'q') {
        game->state = GAME_OVER;
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