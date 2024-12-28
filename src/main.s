# Starting script of RISC-V OS
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "config.s"
.include "consts.s"
.include "macros.s"

.section .text

.global _start

_start:
    la gp, __global_pointer$        # initialize global pointer, see:
                                    # https://www.five-embeddev.com//quickref/global_pointer.html
    la sp, __stack_top              # initialize stack pointer
    mv s0, sp

    push ra

    call sysinit
    call shell_init
    call print_screen

    pop ra

loop:
    wfi
    j loop



