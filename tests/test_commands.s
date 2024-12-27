.include "config.s"
.include "macros.s"

.global _start

.section .text

_start:
    la gp, __global_pointer$        # initialize global pointer, see:
    la sp, __stack_top              # initialize stack pointer
    mv s0, sp

    addi sp, sp, -16

    call sysinit
    call shell_init

    la t0, tests
1:
    lw a0, (t0)
    beqz a0, 2f
    sw t0, 12(sp)
    call run_cmd
    lw t0, 12(sp)
    addi t0, t0, 4
    j 1b
2:
    call show_cursor
    call print_screen

    addi sp, sp, 16



loop:	j loop          # End program; spin forever


run_cmd:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw a0, 8(sp)

    call println

    lw a0, 8(sp)
    call exec_cmd

    lw ra, 12(sp)
    addi sp, sp, 16
    ret


.section .data

cmd1: .string "vi"
cmd2: .string "prompt $"
cmd3: .string "date"
cmd4: .string "prompt"
cmd5: .string "print \"Hello, world!\""

tests:  .word cmd1
        .word cmd2
        .word cmd3
        .word cmd4
        .word cmd5
        .word 0

