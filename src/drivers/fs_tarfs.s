# A "filesystem" on top of a tar file
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.include "macros.s"
.include "config.s"

.global fs_file_info
.global fs_scan_dir
.global fs_read

.section .text

.set HEADER_SIZE, 134

# This function returns a structure, means it writes to the
# caller's stack. Make sure There are 40 bytes avaialble from 0(sp)
# C-style signature: struct FileDesc fs_file_info(u32 offset)
# Arguments
#     a0 - file id (file offset)
fn fs_file_info
    stack_alloc 32
    push s0, 24
    push s1, 20

    addi s0, sp, 32

    li s1, FLASH1_BASE
    add s1, s1, a0

    sw a0, 0(s0)                       # Save file ID

    addi a0, s0, 9                     # Retrive filename
    mv a1, s1
    li a2, 30
    call memcpy
    sb zero, 39(s0)                    # Make sure it ends with zero

    addi a0, s1, 124                   # Retrieve file length
    li a1, 8                           # which is an octal string
    call atoi
    sw a0, 4(s0)                       # and store it in bytes 4-7

    lb t0, 104(s1)                     # load user-byte of file mode (bytes 100-107)
    andi t0, t0, 1                     # check for execution flag

    lbu t1, 9(s0)                      # Set the hidden flag if
    addi t1, t1, -'.'                  # file name starts with '.'
    seqz t1, t1
    slli t1, t1, 1

    or t0, t0, t1
    sb t0, 8(s0)                       # save file flags in byte 8

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
#     a1 - additional parameter (a pointer) added to every call
#          of a callback
# Returns:
#     a0 - The file ID of the last checked file
#          (so for which callback returned 1)
fn fs_scan_dir
    stack_alloc 64
    push a0, 56
    push a1, 52

    mv a0, zero
1:
    call fs_file_info

    lbu t0, 9(sp)
    beqz t0, 3f                        # Exit for empty filename

    pop t0, 56
    mv a0, sp
    pop a1, 52
    jalr t0                            # Execute callback
    bnez a0, 2f                        # Exit if callback returns non zero

                                       # Compute offset to the next header/file
    li t2, 0x200                       # Header and min file-size is 512B
    lw t0, 4(sp)                       # Fetch current file length
    divu t1, t0, t2                    # ...divide it by 512
    remu t0, t0, t2                    # ... and find remainder of it
    snez t0, t0                        # Is it precisely 512B? (t0 = (t0 % 512) != 0)
    addi t1, t1, 1                     # Add 512B for header
    add t1, t1, t0                     # And another 512B if the last block < 512B
    mul t1, t1, t2                     # Multiply num of blocks by block size
    lw a0, (sp)                        # Load current offset from stack
    add a0, a0, t1                     # And add a new one to it

    j 1b

2:  lw a0, (sp)
    j 4f

3:  mv a0, zero

4:  stack_free 64
    ret
endfn


# Read n-bytes from the file and saves them under
# given address. ATM there is no seeking, so it always
# reads from the beginning of the file
# Arguments:
#     a0 - file id
#     a1 - dest addr
#     a2 - count
fn fs_read
    stack_alloc 64
    push a0, 56
    push a1, 52
    push a2, 48

    call fs_file_info

    pop a0, 56                         # destination address

    pop a1, 52                         # file offset
    li t0, FLASH1_BASE
    add a1, a1, t0                     # file header address
    addi a1, a1, 512                   # beginning of the file

    pop a2, 48                         # number of bytes to load
    lw t0, 4(sp)                       # file length
    ble a2, t0, 1f                     # max a2 to file length if greater
        mv a2, t0

1:
    push a2, 48
    call memcpy

    pop a0, 48                         # Return number of copied bytes
    stack_free 64
    ret
endfn

