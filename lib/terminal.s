# Manipulating terminal
# with a terminal using terminal codes
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.include "macros.s"
.include "consts.s"

.global term_show_cursor
.global term_hide_cursor
.global term_reset
.global term_set_screencode
.global term_get_mode
.global term_set_mode

.section .text

fn term_show_cursor
    stack_alloc
    la a0, sc_show_cursor
    syscall SYSFN_PRINT_STR
    stack_free
    ret
endfn


fn term_hide_cursor
    stack_alloc
    la a0, sc_hide_cursor
    syscall SYSFN_PRINT_STR
    stack_free
    ret
endfn


fn term_reset
    stack_alloc
    syscall SYSFN_VIDEO_RESET
    stack_free
    ret
endfn


fn term_set_screencode
    stack_alloc
    syscall SYSFN_SET_SCREENCODE
    stack_free
    ret
endfn


fn term_get_mode
    stack_alloc
    li a0, CFG_SCREEN_MODE
    syscall SYSFN_GET_CFG
    stack_free
    ret
endfn


fn term_set_mode
    stack_alloc
    push a0, 8

    call term_get_mode
    pop t0, 8
    beq a0, t0, 1f

    call clear_screen

    li a0, 50
    call sleep

    pop a0, 8
    syscall SYSFN_VIDEO_SWITCH_MODE

    call scr_init

1:
    stack_free
    ret
endfn

.section .rodata

sc_show_cursor: .byte 0x1b, '[', '?', '2', '5', 'h', 0
sc_hide_cursor: .byte 0x1b, '[', '?', '2', '5', 'l', 0
