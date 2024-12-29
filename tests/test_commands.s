.include "config.s"
.include "macros.s"

.global _start

.section .text

_start:
    la gp, __global_pointer$        # initialize global pointer, see:
    la sp, __stack_top              # initialize stack pointer
    mv s0, sp

    stack_alloc

    call sysinit
    call shell_init

    la t0, tests
1:
    lw a0, (t0)
    beqz a0, 2f
        push t0, 12
        call run_cmd
        pop t0, 12
        addi t0, t0, 4
        j 1b
2:
    call show_cursor
    call print_screen

    stack_free


loop:
    wfi
    j loop          # End program; spin forever


run_cmd:
    stack_alloc
    push a0, 8

    call println

    pop a0, 8
    call exec_cmd

    stack_free
    ret


.section .data

cmd1: .string "vi"
cmd2: .string "prompt $"
cmd3: .string "date"
cmd4: .string "prompt"
cmd5: .string "print \"Hello, world!\""
cmd6: .string "print"

tests:  .word cmd1
        .word cmd2
        .word cmd3
        .word cmd4
        .word cmd5
        .word cmd6
        .word 0

