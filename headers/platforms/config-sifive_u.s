
# Memory
.equ MEM_MIN_ADDR, 0x80000000
.equ MEM_MAX_ADDR, 0x803fffff
.equ STACK_SIZE, 16384

# Screen
.equ SCREEN_WIDTH, 40
.equ SCREEN_HEIGHT, 25

# Devices
.equ UART0_BASE, 0x10010000
.equ UART0_IRQ, 4

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

.equ SYSTEM_TIMER_INTERVAL, 1666666
