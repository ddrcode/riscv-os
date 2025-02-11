#ifndef HAL_UART_H
#define HAL_UART_H

#include "types.h"
#include "buffer.h"

typedef struct UARTDriver UARTDriver;

struct UARTDriver {
    u32 base_addr;
    u32 (*config)(UARTDriver* self, u32 mask, u32 flags);
    void (*putc)(UARTDriver* self, char);
    i32 (*getc)(UARTDriver* self);
    void (*irq_handler)(UARTDriver* self);
    Buffer* buffer;
};

#endif
