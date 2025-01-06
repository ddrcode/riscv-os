.include "macros.s"
.include "config.s"

.macro print_code, str
    la a0, \str
    call uart_puts
.endm

.global video_init

.section .text

.type video_init, @function
video_init:
    stack_alloc
    call video_cls
    call _fill_canvas

    li a0, 12
    li a1, 7
    li a2, '@'
    call _print_char
    stack_free
    ret

video_cls:
    stack_alloc
    print_code SC_CLS
    print_code SC_HOME
    stack_free
    ret

video_repaint:
    ret

_fill_canvas:
    stack_alloc 128
    push s1, 56

    li s1, SCREEN_HEIGHT
1:
    li a0, '\n'
    call uart_putc
    la a0, SC_REVERSED
    call uart_puts
    dec s1
    bnez s1, 1b

    pop s1, 56
    stack_free 128
    ret




# Arguments:
#     a0 - x
#     a1 - y
#     a2 - charcode
_print_char:
    stack_alloc 64
    push a0, 56
    push a1, 52
    push a2, 48

    la a1, SC_CURSOR
    mv a0, sp
    call strcpy

    pop a0, 56
    mv t0, a0
    inc t0
    li t1, 100
    div t0, t0, t1
    addi t0, t0, '0'
    sb t0, 6(sp)

    pop a0, 56
    inc a0
    li t1, 100
    rem t0, a0, t1
    li t1, 10
    div t0, t0, t1
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
    div t0, a0, t1
    addi t0, t0, '0'
    sb t0, 2(sp)

    pop a0, 52
    inc a0
    li t1, 100
    rem t0, a0, t1
    li t1, 10
    div t0, t0, t1
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

    mv a0, sp
    call uart_puts

    stack_free 64
    ret

#----------------------------------------

.section .rodata

SC_CLS:      .ascii  "\033[2J"
SC_HOME:     .ascii  "\033[H"
SC_REVERSED: .ascii  "\x1b[93;41m                                                                    \x1b[0m\0"
SC_NORMAL:   .ascii  "\x1b[0m"
SC_CURSOR:   .ascii  "\33[001;001Hq\0"
