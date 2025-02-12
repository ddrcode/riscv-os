# A "video driver" synchronising the screen memory
# with a terminal using terminal codes
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.macro print_code, str
    li a0, CFG_STD_OUT
    call cfg_get
    la a1, \str
    call uart_puts
.endm

.include "macros.s"
.include "config.s"
.include "consts.s"

.global video_init
.global video_repaint
.global video_reset
.global video_set_screencode

.section .text


fn video_init
    stack_alloc
    call video_cls
    call _fill_canvas
    call video_reset
    stack_free
    ret
endfn


fn video_reset
    li t0, 256
    la t1, screencodes
1:
        dec t0
        slli t2, t0, 2
        add t2, t2, t1
        sw t0, (t2)
        bnez t0, 1b
    ret
endfn


fn video_cls
    stack_alloc
    print_code SC_CLS
    print_code SC_HOME
    stack_free
    ret
endfn


fn _fill_canvas
    stack_alloc 128
    push s1, 120
    push s0, 116

    call_cfg_get CFG_STD_OUT, s0

    li s1, SCREEN_OVER_SERIAL_HBORDER
    slli s1, s1, 1
    addi s1, s1, SCREEN_WIDTH
    addi s1, s1, 16                    # 16 is a lenght of terminal codes)

    mv a0, sp                          # prepare a single line of space characters on the stack
    mv a1, s1
    li a2, ' '
    call memfill

    mv a0, sp                          # copy inversion terminal code at the beginning of the line
    la a1, SC_REVERSED_START
    call strcpy
    li t0, ' '                         # and replace \0 with space
    sb t0, 8(sp)

    mv a0, sp                          # copy end of inversed characters terminal code
    add a0, a0, s1                     # at the end of the string
    addi a0, a0, -8
    la a1, SC_REVERSED_END
    call strcpy

    li s1, SCREEN_OVER_SERIAL_VBORDER
    slli s1, s1, 1
    addi s1, s1, SCREEN_HEIGHT
1:
    mv a0, s0
    mv a1, sp
    call uart_puts

    mv a0, s0
    li a1, '\n'
    call uart_putc

    dec s1
    bnez s1, 1b

    pop s0, 116
    pop s1, 120
    stack_free 128
    ret
endfn


fn video_repaint
    .set Y, 24
    .set X, 20
    .set SCREEN_PTR, 16
    .set PREV_SCREEN_PTR, 12

    stack_alloc 32
    push s0, Y
    push s1, X

    mv a0, zero
    mv a1, sp                          # Get framebuffer info onto the stack
    call fb_info                       # a0 in result is a fb screen data address
    beqz a0, 5f                        # no fb present, exit

    lb s0, 7(sp)                       # get fb height
    lb s1, 8(sp)                       # get fb width

    mul t0, s0, s1                     # fb size in bytes
    lw a0, 1(sp)
    la a1, prev_screen
    add a0, a0, t0                     # end address of a screen
    add a1, a1, t0                     # end address of a copy
1:
    dec s0
    bltz s0, 4f
2:  dec s1
    bgez s1, 3f
    lb s1, 8(sp)                       # get fb width
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
    mv a0, zero
    call fb_get_cursor
    srai a1, a0, 8
    andi a0, a0, 0xff
    li a2, 0
    call _print_char

5:
    pop s0, Y
    pop s1, X
    stack_free 32
    ret
endfn


# Arguments:
#     a0 - x
#     a1 - y
#     a2 - charcode
# TODO Fix that ugliness :-)
fn _print_char
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
    slli t0, t0, 2
    la t1, screencodes
    add t1, t1, t0
    lw t0, (t1)
    sw t0, 10(sp)
    sb zero, 14(sp)

    li a0, CFG_STD_OUT
    call cfg_get
    mv a1, sp
    call uart_puts

    stack_free 64
    ret
endfn


# Arguments
#     a0 - code (0-255)
#     a1 - unicode value
fn video_set_screencode
    stack_alloc
    push a0, 8

    mv a0, a1
    mv a1, sp
    call utf_encode

    pop a0, 8
    la t0, screencodes
    slli t1, a0, 2
    add t0, t0, t1
    lw a1, (sp)
    sw a1, (t0)
    stack_free
    ret
endfn



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

screencodes: .space 1024
