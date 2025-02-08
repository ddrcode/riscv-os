#ifndef _SCREEN_H_
#define _SCREEN_H_

#include "types.h"

// Screen dimensions
#define SCREEN_WIDTH  40
#define SCREEN_HEIGHT 25

// Screen initialization
void scr_init(void);

// Screen clearing
void clear_screen(void);

// Get screen dimensions
void scr_get_size(u32* width, u32* height);

// Cursor manipulation
void get_cursor_pos(u32* x, u32* y);
void set_cursor_pos(u32 x, u32 y);
void show_cursor(void);

// Text output
void scr_print(const char* str);
void scr_println(const char* str);
void scr_backspace(void);

#endif // _SCREEN_H_
