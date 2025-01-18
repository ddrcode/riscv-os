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
    stack_alloc
    push s1, 8

    li t0, 0x880
    csrc mie, t0                       # disable system timer and hw irqs

    la a0, str_test_ilegal_op
    mv a1, zero
    call print_test_name
    call eol

    li t0, 28
    li a1, 4
    divu a0, t0, a1
    li a1, 7
    call assert_eq

    li a0, 33
    li a1, 5
    remu a0, a0, a1
    li a1, 3
    call assert_eq

    li t2, -17
    li t1, 4
    div t0, t2, t1
    mv a0, t0
    li a1, -4
    call assert_eq_signed

    li t2, -17
    li s1, 4
    rem t0, t2, s1
    mv a0, t0
    li a1, -1
    call assert_eq_signed

    pop s1, 8
    stack_free
    ret
endfn


.section .data

str_test_ilegal_op: .string "illegal operation (requiers disabled M-extension for QEMU)"
