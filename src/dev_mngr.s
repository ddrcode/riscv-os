# Device manager
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.include "macros.s"
.include "consts.s"

.global device_add
.global device_get

.section .text

fn device_add
    la t0, devices
    add t0, t0, a0
    sw a1, (t0)
    ret
endfn


fn device_get
    la t0, devices
    add t0, t0, a0
    lw a0, (t0)
    ret
endfn


.section .data

devices: .space DEV_MAX_DEVICES_NO * 4, 0
