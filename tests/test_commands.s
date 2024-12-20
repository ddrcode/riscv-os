.include "config.s"
.include "macros.s"

.section .text
    la gp, __global_pointer$        # initialize global pointer, see:
    la sp, __stack_top              # initialize stack pointer
    mv s0, sp

    call sysinit
    call shell_init

    la a0, cmd1
    call print_str

    call print_screen

loop:	j loop          # End program; spin forever



.section .data

cmd1: .string "edwardize"

