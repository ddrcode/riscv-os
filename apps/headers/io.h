#ifndef STDIO_H
#define STDIO_H

#include "types.h"

i32 printc(char ch);
i32 printw(u32 bytes);
i32 prints(char* str);
i32 println(char* str);
i32 printnum(u32 num);
i32 getc(void);
i32 read_line(char*);

#endif
