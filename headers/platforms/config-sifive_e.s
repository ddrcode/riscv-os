
# Memory
.equ STACK_SIZE, 4096
.equ MIN_STACK_ALLOC_CHUNK, 16

.equ RAM_START_ADDR, 0x80000000
.equ RAM_END_ADDR,   0x80003fff

.equ ROM_START_ADDR, 0x20000000
.equ ROM_END_ADDR,   0x3fffffff

    .equ STACK_SIZE, 4096
.set PMP_CUSTOM_CONFIG, 1

# Screen
.equ SCREEN_WIDTH, 40
.equ SCREEN_HEIGHT, 25

# Devices
.equ UART_0_BASE, 0x10013000
.equ UART_0_IRQ, 3 # Based on Qemu sources

.equ UART_1_BASE, 0x10023000
.equ UART_1_IRQ, 4 # Based on Qemu sources

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
    .equ OUTPUT_DEV, 2
.endif


.equ SCREEN_OVER_SERIAL_HBORDER, 4
.equ SCREEN_OVER_SERIAL_VBORDER, 1

.equ BORDER_COLOR, 1


# System

.equ CPU_FREQUENCY, 32000           # 32kHz

