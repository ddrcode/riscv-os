.include "config.s"
.include "macros.s"

.section .text

.global test_main
.global stackinfo

test_main:
    stack_alloc
    call sysinit
    call stackinfo
    call test_overflow
    stack_free
    ret


stackinfo:
    stack_alloc
    la a0, lab_stack_info
    call prints

    la a0, lab_stack_top
    call prints

        la a0, __stack_top
        la a1, out_str
        li a2, 16
        call utoa

        la a0, out_str
        call prints

    la a0, lab_stack_size
    call prints

        li a0, STACK_SIZE
        la a1, out_str
        li a2, 16
        call utoa

        la a0, out_str
        call prints

    la a0, lab_stack_pointer
    call prints

        mv a0, sp
        la a1, out_str
        li a2, 16
        call utoa

        la a0, out_str
        call prints

    stack_free
    ret

test_overflow:
    stack_alloc

    li t0, STACK_SIZE
    addi t0, t0, 16
    sub sp, sp, t0

    call check_stack


    la a0, tname_overflow
    call prints

    li a0, 1
    li a1, 1
    call assert
    call print_screen

    stack_free
    ret

assert:
    stack_alloc

    la t0, ok
    beq a0, a1, 1f
    la t0, fail
1:
    mv a0, t0
    call prints
    stack_free
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

