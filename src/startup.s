# Starting script of RISC-V OS
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "config.s"
.include "consts.s"
.include "macros.s"

.global _start

.section .text.start

_start:

    # Set the global pointers

    csrr t0, mhartid
    bnez t0, loop                      # initialize only if in hart 0

    la gp, __global_pointer$           # initialize global pointer, see:
                                       # https://www.five-embeddev.com//quickref/global_pointer.html
    la sp, __stack_top                 # initialize stack pointer
    mv s0, sp

    # Initialize the system

    stack_alloc

    call platform_start
    call sysinit

    # Switch to User Mode and run shell

    la t0, main                  # set return address
    csrw mepc, t0

    li t0, 0b11                        # set PCP field of mstatus to 00 (User mode)
    slli t0, t0, 11
    csrc mstatus, t0

    stack_free

    mret                               # Return to user mode

    call panic                         # In case when user mode initialization failed
                                       # it may ignore mret and step here
loop:
    wfi
    j loop


.section .data

