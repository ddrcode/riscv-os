# File manipulation library
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.


# File structure
#
# Byte   Size     Description
# 0-3       4     File ID
# 4-7       4     Size
# 8         1     File flags
# 9-39     31     Name
#
# Flags
# bit 0 - executable
# bit 1 - hidden
# bit 2 - deleted

.include "macros.s"

.global file_ls

.section .text

fn file_ls
    stack_alloc
    la a0, _print_ls_file
    call fs_scan_dir
    stack_free
    ret
endfn


fn _print_ls_file
    stack_alloc 64
    push s1, 56
    mv s1, a0

    lw a0, 4(s1)                       # print file size
    mv a1, sp
    li a2, 10
    call utoa
    li a1, 10
    li a2, ' '
    call str_align_right
    call prints

    lbu t0, 8(s1)
    andi t0, t0, 1
    li t1, '*' - ' '
    mul t0, t0, t1
    addi t0, t0, 0x20

    li a0, 0x20422000                  # print " B  "
    or a0, a0, t0
    call printw

    addi a0, s1, 9                     # print filename
    call prints

    li a0, '\n'
    call printc

    addi a0, zero, 1

    pop s1, 56
    stack_free 64
    ret
endfn

