#include "drivers/uart.h"
#include "types.h"

int test_main() {
    uart_puts("Start typing...\n");

    while (1) {
        char c = uart_getc();
        if (c == 10 || c == 13) {
            uart_putc('\n');
        } else {
            uart_putc(c);
        }
    }
}
