.include "config.s"
.include "macros.s"

.section .text

.global _start

_start:
    la gp, __global_pointer$        # initialize global pointer, see:
    la sp, __stack_top              # initialize stack pointer
    mv s0, sp

    call sysinit
    call test_itoa
    call test_atoi
    call test_str_find_char

loop:	j loop          # End program; spin forever


test_itoa:
    push ra

    la a0, tname_itoa
    call puts

    li a0, 322
    la a1, out_str
    li a2, 10
    call itoa

    la a0, out_str
    la a1, str
    call strcmp

    li a1, 1
    call assert

    pop ra
    ret

test_atoi:
    push ra
    la a0, tname_atoi
    call puts

    la a0, str
    li a1, 10
    call atoi

    li a1, 322
    call assert

    call puts
    pop ra
    ret

test_str_find_char:
    push ra

    la a0, tname_str_find_char
    call puts

    la a0, tname_str_find_char
    li a1, 'x'
    call str_find_char
    li a1, -1
    call assert

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

tname_itoa: .string "Test itoa"
tname_atoi: .string "Test atoi"
tname_str_find_char: .string "Test str_find_char"


