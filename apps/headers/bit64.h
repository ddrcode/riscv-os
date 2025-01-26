#ifndef BIT64_H
#define BIT64_H

#include "types.h"

i32 bitlen64(u32 xlo, u32 xhi);
u32 lshift64(u32 xlo, u32 xhi, i32 val);
i32 getbit64(u32 xlo, u32 xhi, i32 bit);
i32 setbit64(u32 xlo, u32 xhi, i32 bit, i32 val);

#endif

