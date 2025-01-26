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

.global file_scan_dir
.global file_ls
.global file_find

.section .text

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
fn file_scan_dir
    stack_alloc 64
    push a0, 56
    push a1, 52

    mv a0, zero
1:
    mv a1, sp
    syscall SYSFN_FILE_INFO

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


# Finds file by name
# Arguments:
#     a0 - pointer to string with file name
# Returns:
#     a0 - 1 if file found, 0 otherwise
fn file_find
    stack_alloc 16
    mv a1, a0
    la a0, _file_find_cb
    call file_scan_dir
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
