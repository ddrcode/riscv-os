#ifndef TEST_H
#define TEST_H

#include "types.h"

extern int regarr(u32*);

char* citoa(u32 num, char* str, u32 base);
void asser_eq(u32 val, u32 expected);

#endif
