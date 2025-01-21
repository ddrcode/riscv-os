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

    # Run test in user mode

    la t0, test_main
    csrw mepc, t0

    li t0, 0b11                        # set PCP field of mstatus to 00 (User mode)
    slli t0, t0, 11
    csrc mstatus, t0

    stack_free
    mret


loop:
    wfi
    j loop

.section .data

