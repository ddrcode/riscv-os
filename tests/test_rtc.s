.include "config.s"
.include "macros.s"

.global test_main

.section .text

test_main:
    stack_alloc
    call sysinit
    call test_time
    stack_free
    ret

# 17 04067200
test_time:
    stack_alloc

    li t0, 10
1:
    beqz t0, 2f
    push t0, 8

    call rtc_read_time
    push a0, 0

    mv a0, a1
    li t0, 1
    div a0, a0, t0
    la a1, out_str
    li a2, 16
    call itoa

    la a0, out_str
    call puts

    pop a0, 0
    li t0, 1000000
    div a0, a0, t0
    la a1, out_str
    li a2, 16
    call itoa

    la a0, out_str
    call puts

    la a0, '\n'
    call putc

    pop t0, 8
    dec t0
    j 1b

2:
    stack_free
    ret


.section .data

out_str: .fill 32, 1, 0
str: .string "322"
ok: .string "test OK"
fail: .string "test Failed"
