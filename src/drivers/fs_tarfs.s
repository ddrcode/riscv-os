# A "filesystem" on top of a tar file
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.include "macros.s"
.include "config.s"

.global fs_file_info
.global fs_read

.section .text

.set HEADER_SIZE, 134

# Reads a file header based on file id
# Arguments
#     a0 - file id (file offset)
#     a1 - file structure pointer
fn fs_file_info
    stack_alloc 32
    push s0, 24
    push s1, 20

    mv s0, a1

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

    mv a0, s0                          # Move pointer to the structure to a0

    pop s0, 24
    pop s1, 20
    stack_free 32
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

