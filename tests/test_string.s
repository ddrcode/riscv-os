.include "config.s"
.include "macros.s"

.section .text

.global test_main

test_main:
    stack_alloc
    call test_itoa
    call test_atoi
    call test_str_find_char
    stack_free
    ret


test_itoa:
    stack_alloc

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

    stack_free
    ret

test_atoi:
    stack_alloc
    la a0, tname_atoi
    call puts

    la a0, str
    li a1, 10
    call atoi

    li a1, 322
    call assert

    call puts
    stack_free
    ret

test_str_find_char:
    stack_alloc

    la a0, tname_str_find_char
    call puts

    la a0, tname_str_find_char
    li a1, 'x'
    call str_find_char
    li a1, -1
    call assert

    stack_free
    ret


assert:
    stack_alloc

    la t0, ok
    beq a0, a1, 1f
    la t0, fail
1:
    mv a0, t0
    call puts
    stack_free
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


