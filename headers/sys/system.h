#ifndef SYSTEM_H
#define SYSTEM_H

#include "types.h"

i32 sysinit(void);
i32 syscall(i32 fnid, char* args);
i32 checkstack(void);
i32 panic(void);

#endif
