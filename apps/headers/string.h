#ifndef STRING_H
#define STRING_H

#include "types.h"

char* itoa(i32 num, char* str, i32 base);
char* utoa(u32 num, char* str, i32 base);
i32 atoi(const char* str, i32 base);
u32 strlen(const char* str);
i32 strcmp(const char* str1, const char* str2);
char* strcpy(char* dst, const char* src);
i32 str_find_char(char* str, u32 charcode);
i32 str_align_right(char* str, i32 len, char fill);

#endif
