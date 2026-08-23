# Program startup code
# Every program is linked with this file (see apps/Makefile). It prepares
# the C environment, calls main(argc, argv) and exits with its return value.
# See docs/api.md, "Program ABI", for the stack layout at the entry.

.section .text.start

.global _start

_start:
    la t0, __bss_start                 # zero the .bss section (it's not part
    la t1, __bss_end                   # of the binary, see platforms/virt.ld)
1:
    bgeu t0, t1, 2f
    sw zero, (t0)
    addi t0, t0, 4
    j 1b
2:
    call scr_init                      # initialize the framebuffer for app (FIXME)

    lbu a0, 0(sp)                      # argc | Program arguments are on caller's stack
    addi a1, sp, 1                     # argv | (that is run_prog function in shell.s)

    call main                          # execute main function

    li a5, 4                           # call `exit` system function
    ecall                              # with the exit code returned from main

loop:
    j loop
