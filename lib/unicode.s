# Unicode tools
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.include "macros.s"

.global utf_encode

.section .text

# Arguments
#     a0 - unicode value
#     a1 - pointer to a buffer
# Returns
#     a0 - length of a buffer (zero in case of error)
fn utf_encode
    sw zero, (a1)

    li t0, 0x7f
    bgt a0, t0, 1f

        sb a0, 0(a1)
        li a0, 1
        j 5f
1:
    li t0, 0x7ff
    bgt a0, t0, 2f
        srli t0, a0, 6                 # buff[0] = 0xc0 | (ch >> 6)
        ori t0, t0, 0xc0
        sb t0, 1(a1)

        andi t0, a0, 0x3f              # buff[1] = 0x80 | (ch & 0x3f)
        ori t0, t0, 0x80
        sb t0, 0(a1)

        li a0, 2
        j 5f

2:
    li t0, 0xffff
    bgt a0, t0, 3f

        srli t0, a0, 12
        ori t0, t0, 0xe0
        sb t0, 0(a1)

        srli t0, a0, 6
        andi t0, t0, 0x3f
        ori t0, t0, 0x80
        sb t0, 1(a1)

        andi t0, a0, 0x3f
        ori t0, t0, 0x80
        sb t0, 2(a1)

        li a0, 3
        j 5f

3:
    li t0, 0x10FFFF
    bgt a0, t0, 4f

        srli t0, a0, 18
        ori t0, t0, 0xf0
        sb t0, 0(a1)

        srli t0, a0, 12
        andi t0, t0, 0x3f
        ori t0, t0, 0x80
        sb t0, 1(a1)

        srli t0, a0, 6
        and t0, t0, 0x3f
        ori t0, t0, 0x80
        sb t0, 2(a1)

        andi t0, a0, 0x3f
        ori t0, t0, 0x80
        sb t0, 3(a1)

        li a0, 4
        j 5f

4:
    mv a0, zero

5:
    ret
endfn
