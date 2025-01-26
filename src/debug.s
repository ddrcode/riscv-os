# Debug functions. Available only when flag DEBUG
# in config.s is non-zero
# for RISC-V OS
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.include "config.s"

.if DEBUG > 0

.include "macros.s"
.include "consts.s"

.global debug_missing_ret

#------------------------------------------------------------------------------

.section .text

fn debug_missing_ret
    la a0, msg_missing_ret
    syscall SYSFN_PRINT_STR
    ret
endfn

#------------------------------------------------------------------------------

.section .rodata

msg_missing_ret: .string "Panic! Missing ret statement in a function!"

.endif

