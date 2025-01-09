#ifndef UART_H
#define UART_H

#include "types.h"

i32 uart_init(void);
i32 uart_puts(char*);
i32 uart_putc(char);
i32 uart_getc(void);
i32 uart_handle_irq(void);

#endif
