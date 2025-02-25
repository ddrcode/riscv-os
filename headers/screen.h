#ifndef _SCREEN_H_
#define _SCREEN_H_

#include "types.h"

typedef struct {
    u32 x;
    u32 y;
} ScrPoint;

// Screen initialization
void scr_init(void);

// Screen clearing
void clear_screen(void);

// Get screen dimensions
ScrPoint scr_get_size(void);

// Cursor manipulation
ScrPoint get_cursor_pos();
void set_cursor_pos(u32 x, u32 y);
void show_cursor(void);

// Text output
void scr_print(const char* str);
void scr_println(const char* str);
void scr_backspace(void);

#endif // _SCREEN_H_
