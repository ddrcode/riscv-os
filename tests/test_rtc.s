.include "config.s"
.include "macros.s"

.global _start

.section .text

_start:
    la gp, __global_pointer$        # initialize global pointer, see:
    la sp, __stack_top              # initialize stack pointer
    mv s0, sp

    call sysinit
    call test_time

loop:	j loop          # End program; spin forever


# 17 04067200
test_time:
    addi sp, sp, -16
    sw ra, 12(sp)

    li t0, 10
1:
    beqz t0, 2f
    sw t0, 8(sp)

    call rtc_read_time
    sw a0, (sp)

    mv a0, a1
    li t0, 1
    div a0, a0, t0
    la a1, out_str
    li a2, 16
    call itoa

    la a0, out_str
    call puts

    lw a0, (sp)
    li t0, 1000000
    div a0, a0, t0
    la a1, out_str
    li a2, 16
    call itoa

    la a0, out_str
    call puts

    la a0, '\n'
    call putc

    lw t0, 8(sp)
    dec t0
    j 1b

2:
    lw ra, 12(sp)
    addi sp, sp, 16
    ret


.section .data

out_str: .fill 32, 1, 0
str: .string "322"
ok: .string "test OK"
fail: .string "test Failed"
