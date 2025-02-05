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

.section .rodata

sc_show_cursor: .byte 0x1b, '[', '?', '2', '5', 'h', 0
sc_hide_cursor: .byte 0x1b, '[', '?', '2', '5', 'l', 0
