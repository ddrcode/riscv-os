// Tetris: keyboard handling. See tetris.h.

#include "tetris.h"
#include "io.h"

// Processes all the keys pressed since the last call
void handle_input(Game* game) {
    i32 key;
    while ((key = getc()) >= 0) {
        switch (key) {
            case 'q': case 'Q':
                game->quit = true;
                break;
            case 'p': case 'P':
                game_toggle_pause(game);
                break;
            case 'r': case 'R':
                if (game->state == GAME_OVER) game_init(game);
                break;
        }

        if (game->state != PLAYING) continue;

        switch (key) {
            case 'a': case 'A': game_try_move(game, -1, 0); break;       // left
            case 'd': case 'D': game_try_move(game, 1, 0); break;        // right
            case 'w': case 'W': game_try_rotate(game); break;            // rotate
            case 's': case 'S': game_fall(game); break;                  // soft drop
            case ' ':           game_drop(game); break;                  // hard drop
        }
    }
}
