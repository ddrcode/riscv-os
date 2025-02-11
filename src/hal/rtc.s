# RTC HAL
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

# RTC Structure
# byte    size    name
#    0       4    base address
#    4       4    u32 config (self*, u32 mask, u32 flags)
#    8       4    u32 get_secs_from_epoch(self*)
#   12       4    u32 get_raw_data(self*)

.include "macros.s"

.global rtc_get_secs_from_epoch
.global rtc_read_raw_data

.section .text

# Returns seconds from 1970.01.01
# Arguments:
#     a0 - self (pointer to RTCDriver structure)
# Returns:
#     a0 - 32-bit usigned number
fn rtc_get_secs_from_epoch
    stack_alloc
    lw t1, 8(a0)
    jalr t1
    stack_free
    ret
endfn


# Returns raw value from RTC. For different devices
# it may represent different unit. I.e. GoldfishRTC
# returns information in nanoseconds
# Arguments:
#     a0 - self (pointer to RTCDriver structure)
# Returns:
#     a0 - low bits of 64-bit number
#     a1 - high bits of 64-bit number
fn rtc_read_raw_data
    stack_alloc
    lw t1, 12(a0)
    jalr t1
    stack_free
    ret
endfn
