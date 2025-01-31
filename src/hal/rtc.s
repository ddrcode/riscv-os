# RTC HAL
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

# RTC Structure
# byte    size    name
#    0       4    device id (actually base address)
#    4       4    u32 config (u32 base addr, u32 mask, u32 flags)
#    8       4    u32 get_secs_from_epoch()

.include "macros.s"

.global rtc_get_secs_from_epoch

.section .text

fn rtc_get_secs_from_epoch
    stack_alloc

    mv t0, a0
    lw a0, (t0)
    lw t1, 8(t0)
    jalr t1

    stack_free
    ret
endfn
