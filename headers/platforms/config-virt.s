
# Memory
.equ RAM_START_ADDR, 0x80000000
.equ RAM_END_ADDR, 0x803fffff

.equ STACK_SIZE, 4096
.equ MIN_STACK_ALLOC_CHUNK, 16


# Screen
.equ SCREEN_WIDTH, 80
.equ SCREEN_HEIGHT, 25

# Devices
.equ RTC_BASE, 0x101000

.equ UART0_BASE, 0x10000000
.equ UART0_IRQ, 10

.equ PLIC_BASE, 0xc000000

.equ MTIME, 0x0200BFF8
.equ MTIMECMP, 0x02004000


# Output

# Options
# 0 - no output
# bit 0 set - output to framebuffer (writes to memory, can be inspected by gdb)
# bit 1 set - output to serial
# bit 2 set - screen over serial (bit 0 mandatory, don't set bit 1)
# bit 4 set - screen (graphics driver required, bit 0 mandatory, bit 1 or 3 optional)
# At this moment only bit 0 and 1 are supported
# When bit 0 only is set, then the framebuffer content can be checked with gdb
# The option can be provided to assembler with
# `--defsym OUTPUT_DEV=1` (see makefile)
.ifndef OUTPUT_DEV
    .equ OUTPUT_DEV, 1
.endif


.equ SCREEN_OVER_SERIAL_HBORDER, 4
.equ SCREEN_OVER_SERIAL_VBORDER, 1

.equ BORDER_COLOR, 1


# System

.equ CPU_FREQUENCY, 10000000           # 10MHz

