.include "config.s"
.include "macros.s"

.section .text
    la gp, __global_pointer$        # initialize global pointer, see:
    la sp, __stack_top              # initialize stack pointer
    mv s0, sp

    call sysinit
    call test_time

loop:	j loop          # End program; spin forever


test_time:
    push ra
    call rtc_read_time

    la a1, out_str
    li a2, 16
    call itoa

    la a0, out_str
    call puts

    pop ra
    ret


.section .data

out_str: .fill 32, 1, 0
str: .string "322"
ok: .string "test OK"
fail: .string "test Failed"
