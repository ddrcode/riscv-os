.include "config.s"
.include "macros.s"

.macro printchar, char
    li a0, \char
    call putc
.endm

.section .text

.global _start

_start:
    la gp, __global_pointer$        # initialize global pointer, see:
    la sp, __stack_top              # initialize stack pointer
    mv s0, sp

    call sysinit
    call test_bitlen32
    callfn test_udiv32, 7, 3, 2, 1
    callfn test_udiv32, 320, 9, 35, 5
    callfn test_bitlen64, 1, 1, 33
    callfn test_bitlen64, 16, 0, 5
    callfn test_usub64, 0, 1, 1, 0, 0xffffffff, 0
    callfn test_udiv64, 2, 16, 2, 0, 1, 8

loop:
    wfi
    j loop          # End program; spin forever

test_usub64:
    stack_alloc 32
    push a5, 24
    push a4, 20
    push a3, 16
    push a2, 12
    push a1, 8
    push a0, 4

    la a0, tname_usub64
    call puts

    pop a0, 4
    pop a1, 8
    pop a2, 12
    pop a3, 16
    call usub64

    push a1, 8
    pop a1, 20
    call assert

    pop a0, 8
    pop a1, 24
    call assert

    printchar '\n'
    stack_free 32
    ret

test_bitlen32:
    stack_alloc

    la a0, tname_bitlen32
    call puts

    li a0, 129
    call bitlen32

    li a1, 8
    call assert

    callfn putc, '\n'
    stack_free
    ret

test_udiv32:
    stack_alloc 32

    push a3, 24
    push a2, 20
    push a1, 16
    push a0, 12

    la a0, tname_udiv32
    call puts
    callfn putc, '\t'
    callfn putc, '\t'

    pop a0, 12
    pop a1, 16
    call udiv32
    push a1, 8

    pop a1, 20
    call assert

    pop a0, 8
    pop a1, 24
    call assert

    call puts
    printchar '\n'

    stack_free 32
    ret

test_bitlen64:
    stack_alloc
    push a2, 8
    push a1, 4
    push a0, 0

    la a0, tname_bitlen64
    call puts

    pop a0, 0
    pop a1, 4
    call bitlen64

    pop a1, 8
    call assert

    callfn putc, '\n'
    stack_free
    ret

test_udiv64:
    stack_alloc 32
    push a5, 24
    push a4, 20
    push a3, 16
    push a2, 12
    push a1, 8
    push a0, 4

    la a0, tname_udiv64
    call puts

    pop a0, 4
    pop a1, 8
    pop a2, 12
    pop a3, 16
    call udiv64

    push a1, 8
    pop a1, 20
    call assert

    pop a0, 8
    pop a1, 24
    call assert

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
    call puts
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
    call puts

    printchar '='

    pop a0, 4
    la a1, out_str
    li a2, 10
    call itoa

    la a0, out_str
    call puts

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


