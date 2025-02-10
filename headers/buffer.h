#ifndef BUFFER_H
#define BUFFER_H

#include "types.h"

typedef struct {
    byte start[2];
    byte end[2];
    u32 length;
    byte data[];
} Buffer;

void buff_init(Buffer* buff, u8 length);
int buff_read(Buffer* buff);
int buff_write(Buffer* buff, byte data);

#endif
