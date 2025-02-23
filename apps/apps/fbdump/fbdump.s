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
    bnez t0, 1f

        la a0, msg_no_frame_buffer
        call println
        j 3f

1:
    andi t0, a0, 0b100
    beqz t0, 2f

        la a0, msg_terminal
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
fn fb_dump
    stack_alloc 32
    push s0, 20
    push s1, 24
    mv s1, a0

    call _print_frame

    call scr_get_size
    mv s0, a0
    mv t2, a1
    push t2, 16
    push s0, 12

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
    pop s0, 12
    pop t2, 16
    dec t2                             # decrement t2
    push t2, 16
    beqz t2, 4f                        # if t2 is zero jump to 3:
    li a0, '|'
    syscall SYSFN_PRINT_CHAR
    j 1b
4:
    setz a0
    setz a1
    call set_cursor_pos
    call _print_frame

    pop s0, 20
    pop s1, 24
    stack_free 32
    ret
endfn


fn _print_frame
    stack_alloc
    push s0, 4

    call scr_get_size
    addi s0, a0, 2
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

msg_no_frame_buffer: .string "Frame buffer not enabled"
msg_terminal: .string "What you see now is a framebuffer"
