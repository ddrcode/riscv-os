.section .text.start

.global _start

_start:

    call scr_init
    call main

    li a5, 4
    ecall

loop:
    j loop

