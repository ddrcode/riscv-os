#ifndef _STDLIB_H_
#define _STDLIB_H_

typedef unsigned int u32;
typedef int i32;

int syscall(u32, u32, u32, u32, u32, u32);

extern i32 prints(const char*);

#endif
