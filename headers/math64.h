#ifndef MATH64_H
#define MATH64_H

#include "types.h"

U64 uadd64(u32 xlo, u32 xhi, u32 ylo, u32 yhi);
U64 usub64(u32 xlo, u32 xhi, u32 ylo, u32 yhi);
U64 udiv64(u32 nlo, u32 nhi, u32 dlo, u32 dhi);
int ucmp64(u32 xlo, u32 xhi, u32 ylo, u32 yhi);

#endif
