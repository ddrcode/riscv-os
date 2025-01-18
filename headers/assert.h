#ifndef ASSERT_H
#define ASSERT_H

#include "types.h"

extern int regarr(u32*);

void print(char*);
void print_test_name(char*, char*);
void print_summary(void);
void eol(void);

int assert_eq(u32 val, u32 expected);
int assert_arr(u32* val, u32* expected, i32 len);
int assert_str(char* val, char* expected);
int assert_eq_signed(i32 val, i32 expected);

#endif
