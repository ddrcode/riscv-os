.include "config.s"
.include "macros.s"

.macro printchar, char
    li a0, \char
    call printc
.endm

.section .text

.global test_main

test_main:
    stack_alloc
    call sysinit
    call test_bitlen32
    callfn test_udiv32, 7, 3, 2, 1
    callfn test_udiv32, 320, 9, 35, 5
    stack_free
    ret


test_bitlen32:
    stack_alloc

    la a0, tname_bitlen32
    call prints

    li a0, 129
    call bitlen32

    li a1, 8
    call assert

    callfn printc, '\n'
    stack_free
    ret

test_udiv32:
    stack_alloc 32

    push a3, 24
    push a2, 20
    push a1, 16
    push a0, 12

    la a0, tname_udiv32
    call prints
    callfn printc, '\t'
    callfn printc, '\t'

    pop a0, 12
    pop a1, 16
    call udiv32
    push a1, 8

    pop a1, 20
    call assert

    pop a0, 8
    pop a1, 24
    call assert

    call prints
    printchar '\n'

    stack_free 32
    ret

assert:
    stack_alloc
    push a0, 8
    push a1, 4

    call print_comaprison

    pop a0, 8
    pop a1, 4

    la t0, ok
    beq a0, a1, 1f
    la t0, fail
1:
    mv a0, t0
    call prints
    stack_free
    ret

print_comaprison:
    stack_alloc
    push a0, 8
    push a1, 4

    printchar ' '
    printchar '('

    pop a0, 8
    la a1, out_str
    li a2, 10
    call itoa

    la a0, out_str
    call prints

    printchar '='

    pop a0, 4
    la a1, out_str
    li a2, 10
    call itoa

    la a0, out_str
    call prints

    printchar ')'

    stack_free
    ret

.section .data

out_str: .fill 32, 1, 0


.section .rodata

ok: .string " [OK] "
fail: .string " [Failed] "

tname_usub64: .string "Test usub64"
tname_bitlen32: .string "Test bitlen32"
tname_udiv32: .string "Test udiv32"
tname_bitlen64: .string "Test bitlen64"
tname_udiv64: .string "Test udiv64"


