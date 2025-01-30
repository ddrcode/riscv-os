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
    push s0, 4
    push s1, 8
    mv s1, a0

    call _print_frame

#     li a1, UART_BASE
    li s0, SCREEN_WIDTH                # s0 is a  char counter within line
    li t2, SCREEN_HEIGHT               # t2 is a line counter
    push t2, 0
    li a4, 32                          # space character
#     li t0, '|'
#     sb t0, (a1)
    li a0, '|'
    syscall SYSFN_PRINT_CHAR
1:
    lbu t0, (s1)                        # load a single byte to t0
    bge t0, a4, 2f                     # if it's printable character jump to 2
    mv t0, a4                          # otherwise replace character with space
2:
    mv a0, t0
    syscall SYSFN_PRINT_CHAR           # send byte to uart
    dec s0                             # decrement s0
    inc s1                             # increment fb address
    beqz s0, 3f
    j 1b                               # jump to 1
3:
    li a0, '|'
    syscall SYSFN_PRINT_CHAR
    li a0, '\n'                        # EOL character
    syscall SYSFN_PRINT_CHAR
    li s0, SCREEN_WIDTH                # reset s0 to 40
    pop t2, 0
    dec t2                             # decrement t2
    push t2, 0
    beqz t2, 4f                        # if t2 is zero jump to 3:
    li a0, '|'
    syscall SYSFN_PRINT_CHAR
    j 1b
4:
    setz a0
    setz a1
    call set_cursor_pos
    call _print_frame

    pop s0, 4
    pop s1, 8
    stack_free
    ret
endfn


fn _print_frame
    stack_alloc
    push s0, 4

    li s0, 42
1:
    beqz s0, 2f
        li a0, '-'
        syscall SYSFN_PRINT_CHAR
        dec s0
        j 1b
2:
    li a0, '\n'
    syscall SYSFN_PRINT_CHAR

    pop s0, 4
    stack_free
    ret
endfn


.section .rodata

MSG_NO_FRAME_BUFFER: .string "Frame buffer not enabled"
