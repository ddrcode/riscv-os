#ifndef ASSERT_H
#define ASSERT_H

#include "types.h"

extern int regarr(u32*);

void print(char*);
void print_test_name(char*, char*);
int assert_eq(u32 val, u32 expected);
int assert_arr(u32* val, u32* expected, i32 len);

#endif
