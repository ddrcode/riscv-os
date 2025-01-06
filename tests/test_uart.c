#include "drivers/uart.h"
#include "types.h"

int test_main() {
    uart_puts("Start typing (press ~ for clear screen)...\n");

    while (1) {
        char c = uart_getc();
        switch (c) {
            case 10:
            case 13:
                uart_putc('\n');
                break;
            case '~':
                uart_puts("\033[2J");
                uart_puts("\033[H");
                break;
            case 127:
                uart_putc('\b');
                uart_putc(' ');
                uart_putc('\b');
                break;
            default:
                uart_putc(c);
        }
    }
}
