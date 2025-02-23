/*
 * Tetris Game
 *
 * Created by GitHub Copilot
 *
 * This is a simple implementation of the classic Tetris game.
 * The game is played in a terminal and uses Unicode characters
 * for a visually appealing experience.
 *
 * Controls:
 * - Use 'w', 'a', 's', 'd' to move and rotate the pieces.
 * - Press 'p' to pause or resume the game.
 * - Press 'q' to quit the game.
 * - On game over, press 'r' to restart or 'q' to quit.
 */

 #include "tetris.h"

 int main(void) {

     byte mode = term_get_mode();
     term_set_mode(1);

     Game game;
     init_game(&game);
     term_hide_cursor();

     u32 time_since_input = 0;

     while(true) {
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

         // Final draw and wait for 'r' or 'q' key press
         draw_game(&game);

         while(true) {
             i32 ch = getc();
             if (ch == 'r') {
                 init_game(&game);
                 break;
             } else if (ch == 'q') {
                 term_set_mode(mode);
                 term_show_cursor();
                 return 0;
             }
         }
     }
 }
