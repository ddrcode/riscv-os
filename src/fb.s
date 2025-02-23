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
    stack_alloc
    push a1, 8

    sb a0, 0(a1)                       # fb id

    call_cfg_get CFG_SCREEN_DIMENSIONS

    pop a1, 8                          # retrive fb_info structure

    srli t0, a0, 16
    sb t0, 7(a1)                       # screen height

    li t0, 0xffff
    and a0, a0, t0
    sb a0, 8(a1)                       # screen width

    la t0, cursor
    lhu t0, (t0)
    sh t0, 5(a1)                       # cursor position

    la a0, screen
    sw a0, 1(a1)                       # screen buffer address

    stack_free
.else
    mv a0, zero
.endif
    mv a5, zero
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
    mv a5, zero
    ret
endfn


# Returns cursor position
# Arguments: a0 - fb id
fn fb_get_cursor
    la t0, cursor
    lhu a0, (t0)
    mv a5, zero
    ret
endfn

#--------------------------------------

# FIXME introduce heap, rather than hardcoding it
.section .data

cursor: .half 0
.if OUTPUT_DEV & 1
screen: .space SCREEN_WIDTH*SCREEN_HEIGHT
.endif

