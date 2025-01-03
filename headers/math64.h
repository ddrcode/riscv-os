#ifndef MATH64_H
#define MATH64_H

#include "types.h"

u32 uadd64(u32 xlo, u32 xhi, u32 ylo, u32 yhi);
u32 usub64(u32 xlo, u32 xhi, u32 ylo, u32 yhi);
u32 udiv64(u32 nlo, u32 nhi, u32 dlo, u32 dhi);
i32 bitlen64(u32 xlo, u32 xhi);
u32 lshift64(u32 xlo, u32 xhi, i32 val);
i32 getbit64(u32 xlo, u32 xhi, i32 bit);

#endif
