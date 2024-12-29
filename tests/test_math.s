.include "config.s"
.include "macros.s"

.macro printchar, char
    li a0, \char
    call putc
.endm

.macro callfn, name, arg0, arg1=0, arg2=0
    li a0, \arg0
    li a1, \arg1
    li a2, \arg2
    call \name
.endm

.section .text

.global _start

_start:
    la gp, __global_pointer$        # initialize global pointer, see:
    la sp, __stack_top              # initialize stack pointer
    mv s0, sp

    call sysinit
    call test_bitlen32
    call test_udiv32
    call test_bitlen64

loop:
    wfi
    j loop          # End program; spin forever


test_bitlen32:
    push ra

    la a0, tname_bitlen32
    call puts

    li a0, 129
    call bitlen32

    li a1, 8
    call assert

    pop ra
    ret

test_udiv32:
    push ra
    la a0, tname_udiv32
    call puts

    li a0, 320
    li a1, 9
    call udiv32
    mv a4, a1

    li a1, 35
    call assert

    mv a0, a4
    li a1, 5
    dec t0
    call assert

    call puts
    pop ra
    ret

test_bitlen64:
    push ra

    la a0, tname_bitlen64
    call puts

    callfn bitlen64, 1024, 0

    li a1, 11
    call assert

    callfn bitlen64, 7, 1

    li a1, 33
    call assert

    pop ra
    ret

assert:
    push ra, 16
    sw a0, 8(sp)
    sw a1, 4(sp)

    call print_comaprison

    lw a0, 8(sp)
    lw a1, 4(sp)

    la t0, ok
    beq a0, a1, 1f
    la t0, fail
1:
    mv a0, t0
    call puts
    pop ra, 16
    ret

print_comaprison:
    push ra, 16
    sw a0, 8(sp)
    sw a1, 4(sp)

    printchar ' '
    printchar '('

    lw a0, 8(sp)
    la a1, out_str
    li a2, 10
    call itoa

    la a0, out_str
    call puts

    printchar '='

    lw a0, 4(sp)
    la a1, out_str
    li a2, 10
    call itoa

    la a0, out_str
    call puts

    printchar ')'

    pop ra, 16
    ret

.section .data

out_str: .fill 32, 1, 0


.section .rodata

str: .string "322"
ok: .string "\t\t\t[OK]\n"
fail: .string "\t\t\t[Failed]\n"

tname_bitlen32: .string "Test bitlen32"
tname_udiv32: .string "Test udiv32"
tname_bitlen64: .string "Test bitlen64"


