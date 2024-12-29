.include "config.s"
.include "macros.s"

.macro printchar, char
    li a0, \char
    call putc
.endm

.macro callfn, name, arg0, arg1=0, arg2=0, arg3=0
    li a0, \arg0
    li a1, \arg1
    li a2, \arg2
    li a3, \arg3
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
    callfn test_udiv32, 7, 3, 2, 1
    callfn test_udiv32, 320, 9, 35, 5
    callfn test_bitlen64, 1, 1, 33

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

    callfn putc, '\n'
    pop ra
    ret

test_udiv32:
    push ra, 32
    sw a3, 24(sp)
    sw a2, 20(sp)
    sw a1, 16(sp)
    sw a0, 12(sp)

    la a0, tname_udiv32
    call puts
    callfn putc, '\t'
    callfn putc, '\t'

    lw a0, 12(sp)
    lw a1, 16(sp)
    call udiv32
    sw a1, 8(sp)

    lw a1, 20(sp)
    call assert

    lw a0, 8(sp)
    lw a1, 24(sp)
    call assert

    call puts
    callfn putc, '\n'

    pop ra, 32
    ret

test_bitlen64:
    push ra, 16
    sw a2, 8(sp)
    sw a1, 4(sp)
    sw a0, 0(sp)

    la a0, tname_bitlen64
    call puts

    lw a0, 0(sp)
    lw a1, 4(sp)
    call bitlen64

    lw a1, 8(sp)
    call assert

    callfn putc, '\n'
    pop ra, 16
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
ok: .string " [OK] "
fail: .string " [Failed] "

tname_bitlen32: .string "Test bitlen32"
tname_udiv32: .string "Test udiv32"
tname_bitlen64: .string "Test bitlen64"


