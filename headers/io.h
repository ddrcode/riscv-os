#ifndef STDIO_H
#define STDIO_H

#include "types.h"

void printc(char ch);
void printw(u32 bytes);
void prints(const char* str);
void println(const char* str);
void printnum(u32 num);
i32 getc(void);
i32 read_line(char*);

#endif
