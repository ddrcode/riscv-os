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
.include "consts.s"

.global file_ls
.global file_find

.section .text

fn file_ls
    stack_alloc
    la a0, _print_ls_file
    mv a1, zero
    call fs_scan_dir
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


# Finds file by name
# Arguments:
#     a0 - pointer to string with file name
# Returns:
#     a0 - 1 if file found, 0 otherwise
fn file_find
    stack_alloc 16
    mv a1, a0
    la a0, _file_find_cb
    call fs_scan_dir
    stack_free 16
    ret
endfn


fn _file_find_cb
    stack_alloc
    addi a0, a0, 9
    call strcmp
    stack_free
    ret
endfn
