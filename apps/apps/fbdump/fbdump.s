.include "macros.s"
.include "config.s"
.include "consts.s"

.global main

.equ UART_BASE, 0x10000000

.section .text

fn main
    stack_alloc

    li a0, INFO_OUTPUT_DEV             # get active output device(s)
    syscall SYSFN_GET_CFG
    andi t0, a0, 1
    bnez t0, 2f

1:
    la a0, MSG_NO_FRAME_BUFFER
    call println
    j 3f

2:
    mv a0, sp
    syscall SYSFN_FB_INFO

    lw a0, 1(sp)
    beqz a0, 1b
        call fb_dump

3:

    mv a0, zero
    stack_free
    ret
endfn

# Prints the content of screen memory to uart
# TODO use uart_putc function rather than direct access to NS16550A
fn fb_dump
    stack_alloc
    push s1, 8
    mv s1, a0

    call _print_frame

    li a1, UART_BASE
    li t1, SCREEN_WIDTH                # t1 is a  char counter within line
    li t2, SCREEN_HEIGHT               # t2 is a line counter
    li a4, 32                          # space character
    li t0, '|'
    sb t0, (a1)
1:
    lbu t0, (s1)                        # load a single byte to t0
    bge t0, a4, 2f                     # if it's printable character jump to 2
    mv t0, a4                          # otherwise replace character with space
2:
    sb t0, (a1)                        # send byte to uart
    dec t1                             # decrement t1
    inc s1                             # increment fb address
    beqz t1, 3f
    j 1b                               # jump to 1
3:
    li t0, '|'
    sb t0, (a1)
    li t0, '\n'                        # EOL character
    sb t0, (a1)                        # send to UART
    li t1, SCREEN_WIDTH                # reset t1 to 40
    dec t2                             # decrement t2
    beqz t2, 4f                        # if t2 is zero jump to 3:
    li t0, '|'
    sb t0, (a1)
    j 1b
4:
    setz a0
    setz a1
    call set_cursor_pos
    call _print_frame

    pop s1, 8
    stack_free
    ret
endfn


fn _print_frame
    li t0, '-'
    li t1, 42
    la t2, UART_BASE
1:
    beqz t1, 2f
        sb t0, (t2)
        dec t1
        j 1b
2:
    li t0, '\n'
    sb t0, (t2)
    ret
endfn


.section .rodata

MSG_NO_FRAME_BUFFER: .string "Frame buffer not enabled"
