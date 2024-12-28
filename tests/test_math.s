.include "config.s"
.include "macros.s"

.section .text

.global _start

_start:
    la gp, __global_pointer$        # initialize global pointer, see:
    la sp, __stack_top              # initialize stack pointer
    mv s0, sp

    call sysinit
    call test_bitlen32
    call test_udiv32

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

    li a0, 129
    li a1, 8
    call udiv32
    mv a5, a1

    li a1, 16
    call assert

    mv a0, a5
    li a1, 1
    call assert

    call puts
    pop ra
    ret


assert:
    push ra

    la t0, ok
    beq a0, a1, 1f
    la t0, fail
1:
    mv a0, t0
    call puts
    pop ra
    ret

.section .data

out_str: .fill 32, 1, 0


.section .rodata

str: .string "322"
ok: .string "\t\t\t[OK]\n"
fail: .string "\t\t\t[Failed]\n"

tname_bitlen32: .string "Test bitlen32"
tname_udiv32: .string "Test udiv32"


