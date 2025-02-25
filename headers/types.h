#ifndef TYPES_H

#define TYPES_H

typedef signed int i32;
typedef unsigned int u32;

typedef signed char i8;
typedef unsigned char u8;

typedef unsigned char byte;

typedef u8 bool;
#define true 1
#define false 0

typedef struct {
    u32 low;
    u32 high;
} U64;

typedef struct {
    i32 low;
    i32 high;
} I64;

typedef struct {
    u32 val;
    u32 err;
} Result;

#endif
