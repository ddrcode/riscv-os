# Starting script of RISC-V OS
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "config.s"
.include "consts.s"
.include "macros.s"

.section .text.start

.global _start

_start:
    csrr t0, mhartid
    bnez t0, loop                      # initialize only if in hart 0

    la gp, __global_pointer$           # initialize global pointer, see:
                                       # https://www.five-embeddev.com//quickref/global_pointer.html
    la sp, __stack_top                 # initialize stack pointer
    mv s0, sp

    stack_alloc

    call sysinit
    call irq_init
    call shell_init

    la a5, 1
    ecall

    call shell_command_loop

    stack_free

loop:
    wfi
    j loop



