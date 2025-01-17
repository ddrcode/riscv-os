.include "config.s"
.include "macros.s"

.section .text

.global test_main

fn test_main
    stack_alloc
    call irq_init
    call test_illegal_op
    call print_summary
    stack_free
    ret
endfn

fn test_illegal_op
    li t0, 0x880
    csrc mie, t0                       # disable system timer and hw irqs

    la a0, str_test_ilegal_op
    mv a1, zero
    call print_test_name

    li a0, 28
    li a1, 4
    divu a0, a0, a1
    li a1, 7
    call assert_eq

    ret
endfn


.section .data

str_test_ilegal_op: .string "illegal operation (requiers disabled M-extension for QEMU)"
