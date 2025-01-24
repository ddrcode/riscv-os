.section .text.start

.extern main
.global _start

_start:

    # addi sp, sp, -16
    # sw ra, 12(sp)

    # li a0, '!'
    # li a5, 21
    # ecall

    call main

    # li a5, 21
    # ecall

    li a5, 4
    ecall

    # lw ra, 12(sp)
    # addi sp, sp, 16

1:
    j 1b
