#ifndef STRING_H
#define STRING_H

#include "types.h"

i32 itoa(u32 num, char* str, i32 base);
u32 atoi(char* str, i32 base);
i32 strlen(char* str);
i32 strcmp(char* str1, char* str2);
i32 str_find_char(char* str, u32 charcode);

#endif
