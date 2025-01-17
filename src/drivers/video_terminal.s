# A "video driver" synchronising the screen memory
# with a terminal using terminal codes
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.macro print_code, str
    la a0, \str
    call uart_puts
.endm

.include "macros.s"
.include "config.s"

.global video_init
.global video_repaint

.section .text

.type video_init, @function
video_init:
    stack_alloc
    call video_cls
    call _fill_canvas

    stack_free
    ret

video_cls:
    stack_alloc
    print_code SC_CLS
    print_code SC_HOME
    stack_free
    ret


_fill_canvas:
    stack_alloc 128
    push s1, 120

    li s1, SCREEN_OVER_SERIAL_HBORDER
    slli s1, s1, 1
    addi s1, s1, SCREEN_WIDTH
    addi s1, s1, 16

    mv a0, sp
    mv a1, s1
    li a2, ' '
    call memfill

    mv a0, sp
    la a1, SC_REVERSED_START
    call strcpy
    li t0, ' '
    sb t0, 8(sp)

    mv a0, sp
    add a0, a0, s1
    addi a0, a0, -8
    la a1, SC_REVERSED_END
    call strcpy

    add t0, s1, sp
    sb zero, (t0)

    # addi a0, zero, 1
    # mv a1, a0
    # mv a2, zero
    # call _print_char

    li s1, SCREEN_OVER_SERIAL_VBORDER
    slli s1, s1, 1
    addi s1, s1, SCREEN_HEIGHT
1:
    mv a0, sp
    call uart_puts
    li a0, '\n'
    call uart_putc
    dec s1
    bnez s1, 1b

    pop s1, 120
    stack_free 128
    ret



.type video_repaint, @function
video_repaint:
    .set Y, 24
    .set X, 20
    .set SCREEN_PTR, 16
    .set PREV_SCREEN_PTR, 12

    stack_alloc 32
    push s0, Y
    push s1, X

    li s0, SCREEN_HEIGHT
    li s1, SCREEN_WIDTH

    mul t0, s0, s1
    la a0, screen
    la a1, prev_screen
    add a0, a0, t0
    add a1, a1, t0
1:
    dec s0
    bltz s0, 4f
2:  dec s1
    bgez s1, 3f
    li s1, SCREEN_WIDTH
    j 1b
3:
    dec a0
    dec a1
    lbu t0, (a0)
    lbu t1, (a1)
    beq t0, t1, 2b

    sb t0, (a1)
    push a0, SCREEN_PTR
    push a1, PREV_SCREEN_PTR

    mv a0, s1
    mv a1, s0
    mv a2, t0
    call _print_char

    pop a0, SCREEN_PTR
    pop a1, PREV_SCREEN_PTR

    j 2b
4:
    call get_cursor_pos
    li a2, 0
    call _print_char

    pop s0, Y
    pop s1, X
    stack_free 32
    ret


# Arguments:
#     a0 - x
#     a1 - y
#     a2 - charcode
# TODO Fix that uglyness :-)
_print_char:
    stack_alloc 64

    li t0, SCREEN_OVER_SERIAL_HBORDER
    add a0, a0, t0

    li t0, SCREEN_OVER_SERIAL_VBORDER
    add a1, a1, t0

    push a0, 56
    push a1, 52
    push a2, 48

    la a1, SC_CURSOR_AND_CHAR
    mv a0, sp
    call strcpy

    pop a0, 56
    mv t0, a0
    inc t0
    li t1, 100
    divu t0, t0, t1
    addi t0, t0, '0'
    sb t0, 6(sp)

    pop a0, 56
    inc a0
    li t1, 100
    rem t0, a0, t1
    li t1, 10
    divu t0, t0, t1
    addi t0, t0, '0'
    sb t0, 7(sp)

    pop a0, 56
    inc a0
    li t1, 100
    rem t0, a0, t1
    li t1, 10
    rem t0, t0, t1
    addi t0, t0, '0'
    sb t0, 8(sp)


    pop a0, 52
    inc t0
    li t1, 100
    divu t0, a0, t1
    addi t0, t0, '0'
    sb t0, 2(sp)

    pop a0, 52
    inc a0
    li t1, 100
    rem t0, a0, t1
    li t1, 10
    divu t0, t0, t1
    addi t0, t0, '0'
    sb t0, 3(sp)

    pop a0, 52
    inc a0
    li t1, 100
    rem t0, a0, t1
    li t1, 10
    rem t0, t0, t1
    addi t0, t0, '0'
    sb t0, 4(sp)

    pop t0, 48
    sb t0, 10(sp)
    sb zero, 11(sp)

    mv a0, sp
    call uart_puts

    stack_free 64
    ret


#----------------------------------------

.section .rodata

SC_CLS:      .asciz  "\033[2J"
SC_HOME:     .asciz  "\033[H"
# see https://en.wikipedia.org/wiki/ANSI_escape_code#In_shell_scripting
SC_REVERSED_START: .asciz  "\x1b[0;100mw"
SC_REVERSED_END: .asciz  "\x1b[0m"
SC_CURSOR_AND_CHAR:   .asciz  "\33[000;000H\0"

#---------------------------------------

.section .data

prev_screen: .space SCREEN_WIDTH*SCREEN_HEIGHT

