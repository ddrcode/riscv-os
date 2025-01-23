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

    sw a0, 0(s0)                       # Save file ID

    addi a0, s0, 8                     # Retrive filename
    mv a1, s1
    li a2, 32
    call memcpy
    sb zero, 39(s0)                    # Make sure it ends with zero

    addi a0, s1, 124                   # Retrieve file length
    li a1, 8                           # which is a string in base-8
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
# Returns:
#     a0 - The file ID of the last checked file
#          (so for which callback returned 0)
#     a5 - 1 - if callback never returned 0
fn fs_scan_dir
    stack_alloc 48
    push a0, 40

    mv a0, zero
1:
    call fs_file_info

    lbu t0, 8(sp)
    beqz t0, 2f                        # Exit for empty filename

    pop t0, 40
    mv a0, sp
    jalr t0                            # Execute callback
    beqz a0, 2f                        # Exit if callback returns 0

                                       # Compute offset of the next file
    li t2, 0x200                       # Header and min lbock-size is 512B
    lw t0, 4(sp)                       # Fetch current file length
    divu t1, t0, t2
    remu t0, t0, t2
    snez t0, t0                        # Is it precisely 512B?
    addi t1, t1, 1                     # Add 512B for header
    add t1, t1, t0                     # And another 512B if the last block < 512B
    mul t1, t1, t2                     # Multiply num of blocks by block size
    lw a0, (sp)                        # Load current offset
    add a0, a0, t1                     # And add a new one to it

    j 1b

2:
    stack_free 48
    ret
endfn
