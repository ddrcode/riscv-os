.include "config.s"
.include "macros.s"

.section .text

.global _start
.global stackinfo

_start:
    la gp, __global_pointer$        # initialize global pointer, see:
    la sp, __stack_top              # initialize stack pointer
    mv s0, sp

    call sysinit
    call stackinfo
    call test_overflow

loop:
    wfi
    j loop          # End program; spin forever


stackinfo:
    push ra
    la a0, lab_stack_info
    call puts

    la a0, lab_stack_top
    call puts

        la a0, __stack_top
        la a1, out_str
        li a2, 16
        call itoa

        la a0, out_str
        call puts

    la a0, lab_stack_size
    call puts

        li a0, STACK_SIZE
        la a1, out_str
        li a2, 16
        call itoa

        la a0, out_str
        call puts

    la a0, lab_stack_pointer
    call puts

        mv a0, sp
        la a1, out_str
        li a2, 16
        call itoa

        la a0, out_str
        call puts

    pop ra
    ret

test_overflow:
    push ra

    li t0, STACK_SIZE
    addi t0, t0, 16
    sub sp, sp, t0

    call check_stack


    la a0, tname_overflow
    call puts

    li a0, 1
    li a1, 1
    call assert
    call print_screen

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

#------------------------------------------------------------------------------

.section .data

out_str: .fill 32, 1, 0

#------------------------------------------------------------------------------

.section .rodata

str: .string "322"
ok: .string "\t\t\t[OK]\n"
fail: .string "\t\t\t[Failed]\n"

lab_stack_info: .string "\nStack info"
lab_stack_top: .string "\nStack top: 0x"
lab_stack_size: .string "\nStack size: 0x"
lab_stack_pointer: .string "\nStack pointer: 0x"

tname_overflow: .string "\nTest stack overflow"

