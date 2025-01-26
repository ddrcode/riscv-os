# (Text) Screen handling functions
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See the LICENSE file for license details.

.include "macros.s"
.include "config.s"
.include "consts.s"

.global fb_info
.global fb_get_cursor
.global fb_set_cursor

.section .text


# fb_info structure:
# byte    length    name    description
#    0         1    id      framebuffer id
#    1         4    addr    address
#    5         2    cursor
#    7         1    heght
#    8         1    width


# Gives a structure representing current (active) framebuffer
# Arguments:
#     a0 - fb id
#     a1 - pointer to fb_info structure
# Returns
#     a0 base_addr of the active fb or 0 if none
fn fb_info
.if OUTPUT_DEV & 1
    li t0, 1
    sb t0, 0(a1)                       # fb id

    la t0, cursor
    lhu t0, (t0)
    sh t0, 5(a1)

    li t0, SCREEN_HEIGHT
    sb t0, 7(a1)

    li t0, SCREEN_WIDTH
    sb t0, 8(a1)

    la t0, screen
    sw t0, 1(a1)

    mv a0, t0
.else
    mv a0, zero
.endif
    ret
endfn


# Arguments
#    a0 - fb id
#    a1 - cursor x
#    a2 - cursor y
# returns cursor 16-bit number representing cursor in a0
fn fb_set_cursor
    slli t0, a2, 8
    or a0, a1, t0
    la t0, cursor
    sh a0, (t0)
    ret
endfn


# Returns cursor position
# Arguments: a0 - fb id
fn fb_get_cursor
    la t0, cursor
    lhu a0, (t0)
    ret
endfn

#--------------------------------------

# FIXME introduce heap, rather than hardcoding it
.section .data

cursor: .half 0
.if OUTPUT_DEV & 1
screen: .space SCREEN_WIDTH*SCREEN_HEIGHT
.endif

