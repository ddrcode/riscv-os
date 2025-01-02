#ifndef TEST_H
#define TEST_H

#include "types.h"

extern int regarr(u32*);

char* citoa(u32 num, char* str, u32 base);
void assert_eq(u32 val, u32 expected);
void assert_arr(u32* val, u32* expected, i32 len);
void print(char*);

#endif
