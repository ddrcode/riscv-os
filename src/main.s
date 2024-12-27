.include "config.s"
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

loop:	j loop



