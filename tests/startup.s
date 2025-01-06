.section .text.start

.globl _start
_start:
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    la sp, __stack_top
    mv s0, sp

    call sysinit
    call test_main


loop:
    wfi
    j loop

