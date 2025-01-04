#ifndef MEM_H
#define MEM_H

#include "types.h"

u32 memcpy(u32 dst, u32 src, i32 cnt);
u32 memfill(u32 start, i32 cnt, i32 value);
i32 mem_reverse(char* start, i32 cnt);

#endif
