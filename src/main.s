.include "macros.s"

.section .text
    la sp, __stack_top              # initialize stack pointer
    mv s0, sp

    call clear_screen
    # mv a0, zero
    # li a0, 0
    # li a1, 5
    # call set_cursor_pos
    la a0, helloworld   # Load address of string
    call print_str
    la a0, another_str
    call print_str
    call print_screen
    # li a1, UART_BASE    # Load uart tx base address
    # call puts           # Print string

loop:	j loop          # End program; spin forever



.section .data
helloworld: .string "Hello World! This string is longer than 40 characters"
another_str: .string "Second string"
cursor: .half 0
screen: .fill 1000, 1, 32

