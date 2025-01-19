.include "config.s"
.include "consts.s"
.include "macros.s"

.section .text.start

.global _start
_start:
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    la sp, __stack_top
    mv s0, sp

    stack_alloc

    call irq_init                      # enable IRQ's
    li t0, 0x880
    csrc mie, t0                       # but disable system timer and hw irqs

    call sysinit
    call test_main
    stack_free


loop:
    wfi
    j loop

.section .data

