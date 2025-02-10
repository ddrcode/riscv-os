# Generic buffer
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "macros.s"

.global buff_init
.global buff_write
.global buff_read

.section .text

# Arguments:
#    a0 - address
#    a1 - length
#    a2 - data address
fn buff_init
    sw zero, (a0)
    sw a1, 4(a0)
    sw a2, 8(a0)
    ret
endfn


# Arguments:
#    a0 - address
fn buff_read
    mv t2, a0
    lhu t0, (t2)                       # load start pos
    lhu t1, 2(t2)                      # load end pos
    beq t0, t1, 2f                     # start==end, empty buffer

    lhu t1, 4(t2)                      # load buff length
    lw a2, 8(t2)                       # load data addr
    add a2, a2, t0                     # and compute start pos
    lbu a0, (a2)                       # load byte from start pos

    inc t0                             # compute new start
    blt t0, t1, 1f
        mv t0, zero                    # overflow when start==length
1:
    sh t0, 0(t2)                      # store new start
    j 3f

2:
    li a0, -1
3:
    ret
endfn


# Arguments:
#     a0 - buffer address
#     a1 - value
fn buff_write
    lhu t0, 0(a0)
    lhu t1, 2(a0)
    sub t2, t1, t0
    bgez t2, 1f
        sub t2, t0, t1
1:
    lhu t0, 4(a0)
    dec t0
    beq t0, t2, 3f                     # buffer is full

    lw a2, 8(a0)
    add a2, a2, t1
    sb a1, (a2)
    blt t1, t0, 2f                     # end pointer at the end of buffer
        li t1, -1
2:
    inc t1
    sh t1, 2(a0)
    li a0, 1
    j 4f
3:
    li a0, -1
4:
    ret
endfn
