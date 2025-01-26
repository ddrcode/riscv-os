.include "macros.s"
.include "consts.s"

.global main

.section .text


fn main
    stack_alloc
    la a0, _print_ls_file
    mv a1, zero
    call file_scan_dir
    mv a5, zero
    mv a0, zero
    stack_free
    ret
endfn


fn _print_ls_file
    stack_alloc 64
    push s1, 56
    mv s1, a0

    lbu t0, 8(s1)                      # load file flags
    andi t0, t0, 0b10
    bnez t0, 1f                        # Exit if it's a hidden file

    lw a0, 4(s1)                       # print file size
    mv a1, sp
    li a2, 10
    call utoa
    li a1, 10
    li a2, ' '
    call str_align_right
    call prints

    lbu t0, 8(s1)                      # load file flags again
    andi t0, t0, 1
    li t1, '*' - ' '
    mul t0, t0, t1
    addi t0, t0, 0x20

    li a0, 0x20422000                  # print " B  " or " B *"
    or a0, a0, t0
    call printw

    addi a0, s1, 9                     # print filename
    call prints

    li a0, '\n'
    call printc

1:
    mv a0, zero

    pop s1, 56
    stack_free 64
    ret
endfn


