.include "config.s"
.include "macros.s"

.section .text
    la sp, __stack_top              # initialize stack pointer
    mv s0, sp

    call clear_screen
    la a0, helloworld   # Load address of string
    call println
    li a0, 5
    li a1, 23
    call set_cursor_pos
    la a0, another_str
    call println
    call scroll
    call show_cursor

    la a1, screen
    addi a1, a1, 80
    li a0, 256
    li a2, 10
    call itoa

    la a0, screen
    addi a0, a0, 80
    li a1, 4
    call mem_reverse

    call print_screen

loop:	j loop          # End program; spin forever



.section .data

helloworld: .string "Hello World! This string is longer than 40 characters"
another_str: .string "Second string"
cursor: .half 0
screen: .fill SCREEN_WIDTH*SCREEN_HEIGHT, 1, 32

