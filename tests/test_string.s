.include "config.s"
.include "macros.s"

.section .text
    la gp, __global_pointer$        # initialize global pointer, see:
    la sp, __stack_top              # initialize stack pointer
    mv s0, sp

    call sysinit
    call test_itoa

loop:	j loop          # End program; spin forever


test_itoa:
    push ra

    li a0, 322
    la a1, out_str
    li a2, 10
    call itoa

    la a0, out_str
    la a1, str
    call strcmp
    mv t0, a0

    la a0, fail
    beqz t0, 1f
    la a0, ok
1:
    call puts
    pop ra
    ret


.section .data

out_str: .fill 32, 1, 0
str: .string "322"
ok: .string "test OK"
fail: .string "test Failed"
