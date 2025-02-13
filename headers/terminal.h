#ifndef TERMINAL_H
#define TERMINAL_H

#include "types.h"

void term_show_cursor(void);
void term_hide_cursor(void);
void term_reset(void);
void term_set_screencode(byte code, u32 unicode);

#endif
