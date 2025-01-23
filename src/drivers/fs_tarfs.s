# A "filesystem" on top of a tar file
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.include "macros.s"
.include "config.s"

.global fs_file_info
.global fs_scan_dir


.section .text

.set HEADER_SIZE, 134

# This function returns a structure, means it writes to the
# caller's stack. Make sure There are 40 bytes avaialble from 0(sp)
# C-style signature: struct FileDesc fs_file_info(u32 offset)
fn fs_file_info
    stack_alloc 32
    push s0, 24
    push s1, 20

    addi s0, sp, 32

    li s1, FLASH1_BASE
    add s1, s1, a0

    addi a0, s0, 8                     # Retrive filename
    mv a1, s1
    li a2, 32
    call memcpy
    sb zero, 39(s0)                    # Make sure it ends with zero

    # mv a0, sp
    addi a0, s1, 124
    # li a2, 12
    # call memcpy

    # mv a0, sp
    li a1, 8
    call atoi
    sw a0, 4(s0)

    pop s0, 24
    pop s1, 20
    stack_free 32
    ret
endfn


# Scans current folder item by item
# executing provided function for each one
# The scanning stops when the function returns 0
# Arguments:
#     a0 - pointer to a function executed for every file.
#          The function takes pointer to a file structure
fn fs_scan_dir
    stack_alloc 64
    push a0, 56

    mv a0, zero
    call fs_file_info

    pop t0, 56
    mv a0, sp
    jalr t0

    # addi a0, sp, 8
    # call prints
    #
    # li a0, ' '
    # call printc
    #
    # lw a0, 4(sp)
    # addi a1, sp, 40
    # li a2, 10
    # call utoa
    # call println

    stack_free 64
    ret
endfn
