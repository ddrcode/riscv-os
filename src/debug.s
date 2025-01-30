# Debug functions. Available only when flag DEBUG
# in config.s is non-zero
# for RISC-V OS
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.include "config.s"


.include "macros.s"
.include "consts.s"

.global debug_prints
.global debug_printc

.if DEBUG > 0
.global debug_missing_ret
.endif

#------------------------------------------------------------------------------

.section .text

.if DEBUG > 0
fn debug_missing_ret
    la a0, msg_missing_ret
    syscall SYSFN_PRINT_STR
    ret
endfn
.endif


fn debug_prints
.if DEBUG > 0
    stack_alloc
    push a0, 8

    li a0, CFG_STD_DEBUG
    call cfg_get

    pop a1, 8
    call uart_puts

    stack_free
.endif
    ret
endfn

fn debug_printc
.if DEBUG > 0
    stack_alloc
    push a0, 8

    li a0, CFG_STD_DEBUG
    call cfg_get

    pop a1, 8
    call uart_putc

    stack_free
.endif
    ret
endfn

#------------------------------------------------------------------------------

.section .rodata

.if DEBUG > 0
msg_missing_ret: .string "Panic! Missing ret statement in a function!"
.endif

