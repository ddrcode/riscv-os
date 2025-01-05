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

.global rtc_read_time
.global rtc_time_in_sec
.global rtc_get_date
.global rtc_get_time

.equ NSEC_PER_SEC, 1000000000
.equ SECS_PER_DAY, 86400

.section .text

# Reads Goldfish RTC and returns a 64-bit number containing
# a number of nanoseconds since 01.01.1970.
# This is a row data - as provided by the RTC itself
# Arguments:  none
# Returns
# a0 - low bits
# a1 - high bits
.type rtc_read_time, @function
rtc_read_time:
    li t0, RTC_BASE
    lw a0, (t0)
    lw a1, 4(t0)
    ret


# Converts row date/time reading from Goldfish RTC
# into a number of seconds since 1970-01-01
# It outputs two 32-bit numbers (a0-low, a1-high)
# but a1 can be ignored, as it'll be 0 for dates
# before 2106-02-07 06:28:15
.type rtc_time_in_sec, @function
rtc_time_in_sec:
    stack_alloc
    call rtc_read_time
    li a2, NSEC_PER_SEC
    setz a3
    call udiv64
    stack_free
    ret


# Returns current date - as provided by Goldfish RTC
# in 4-byte date structure (dow | year | month | day).
# See get_date in time.s for details
# Arguments: none
# Returns:
#     a0 - 4-byte date structure of current RTC date
.type rtc_get_date, @function
rtc_get_date:
    stack_alloc
    call rtc_time_in_sec               # a0 contains secs from 1.01.1970
    call get_date
    stack_free
    ret


# Returns current time - as provided by Goldfish RTC
# in 4-byte time structure (0 | hours| minutes | seconds).
# See get_time in time.s for details.
# Arguments: none
# Returns:
#     a0 - 4-byte time structure of current RTC time
.type rtc_get_time, @function
rtc_get_time:
    stack_alloc
    call rtc_time_in_sec               # a0 contains secs from 1.01.1970
    call get_time
    stack_free
    ret

