.include "macros.s"

.global putc
.global puts
.global getc

.section .text

.type putc, @function
putc:
    stack_alloc 4
    call uart_putc
    stack_free 4
    ret

.type puts, @function
puts:
    stack_alloc 4
    call uart_puts
    stack_free 4
    ret

.type getc, @function
getc:
    stack_alloc 4
    call uart_getc
    stack_free 4
    ret
