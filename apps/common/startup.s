.section .text.start

.global _start

_start:


    lbu a0, 0(sp)                      # argc | Program arguments are on caller's stack
    addi a1, sp, 1                     # argv | (that is run_prog function in shell.s)

    call scr_init                      # initialize the framebuffer for app (FIXME)

    call main                          # execute main function

    li a5, 4                           # call `exit` system function
    ecall                              # with the exit code returned from main

loop:
    j loop

