# Driver implementation of Goldfish RTC
# For references here is implementation for Linux
# https://github.com/torvalds/linux/blob/master/drivers/rtc/rtc-goldfish.c#L110
# https://elixir.bootlin.com/linux/v6.12.6/source/drivers/rtc/lib.c#L142
# And Goldfish documentation
# https://android.googlesource.com/platform/external/qemu/+/master/docs/GOLDFISH-VIRTUAL-HARDWARE.TXT
#
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "config.s"
.include "macros.s"

.global goldfish_rtc_init

.equ NSEC_PER_SEC, 1000000000

.section .text

# Reads Goldfish RTC and returns a 64-bit number containing
# a number of nanoseconds since 01.01.1970.
# This is a row data - as provided by the RTC itself
# Arguments
#     a0 - self (pointer to RTCDriver structure)
# Returns
#     a0 - low bits
#     a1 - high bits
fn goldfish_rtc_read_time
    lw t0, (a0)
    lw a0, (t0)
    lw a1, 4(t0)
    ret
endfn


# Converts row date/time reading from Goldfish RTC
# into a number of seconds since 1970-01-01
# It outputs two 32-bit numbers (a0-low, a1-high)
# but a1 can be ignored, as it'll be 0 for dates
# before 2106-02-07 06:28:15
# Arguments:
#     a0 - self (pointer to RTCDriver structure)
# Returns
#     a0 - 32-bit unsigned number with seconds
fn goldfish_rtc_time_in_sec
    stack_alloc
    call goldfish_rtc_read_time
    li a2, NSEC_PER_SEC
    setz a3
    call udiv64
    stack_free
    ret
endfn


# Noting to configure, but the function must exist
# to follow the HAL conventoin
# Arguments:
#     a0 - self (pointer to RTCDriver structure)
fn goldfish_rtc_config
    li a0, 1                           # Device enabled
    ret
endfn


# Arguments
#     a0 - pointer to rtc driver structure
#     a1 - base address
fn goldfish_rtc_init
    sw a1, 0(a0)

    la t0, goldfish_rtc_config
    sw t0, 4(a0)

    la t0, goldfish_rtc_time_in_sec
    sw t0, 8(a0)

    la t0, goldfish_rtc_read_time
    sw t0, 12(a0)

    ret
endfn
