# System function
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.include "macros.s"
.include "consts.s"
.include "config.s"

.global cfg_set
.global cfg_get

#----------------------------------------

.section .text

# Arguments:
#     a0 - flag
#     a1 - value
fn cfg_set
    la t0, sysinfo
    add t0, t0, a0
    sb a1, (t0)
    ret
endfn


# Arguments:
#     a0 - flag
fn cfg_get
    la t0, sysinfo
    add t0, t0, a0
    lbu a0, (t0)
    ret
endfn


#----------------------------------------

.section .data

sysinfo:
output_dev:     .byte      0
