# Driver implementation of Goldfish RTC
# For references here is implementation for Linux
# https://github.com/torvalds/linux/blob/master/drivers/rtc/rtc-goldfish.c#L110
# https://elixir.bootlin.com/linux/v6.12.6/source/drivers/rtc/lib.c#L142
# And Goldfish documentation
# https://android.googlesource.com/platform/external/qemu/+/master/docs/GOLDFISH-VIRTUAL-HARDWARE.TXT

.section .text

.global rtc_read_time

# Returns 64-bit number containing a number of nanoseconds
# since 01.01.1970.
# a0 - low bits
# a1 - high bits
rtc_read_time:
    li t0, RTC_BASE
    lw a1, (t0)
    lw a0, 4(t0)
    ret

