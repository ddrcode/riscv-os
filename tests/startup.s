.section .text.start

.globl _start
_start:
    la gp, __global_pointer$

    la sp, __stack_top
    mv s0, sp

    call test_main


loop:
    wfi
    j loop

