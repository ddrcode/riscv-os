# Memory
.equ MEM_MIN_ADDR, 0x80000000
.equ MEM_MAX_ADDR, 0x803fffff
.equ STACK_SIZE, 4096

# Screen
.equ SCREEN_WIDTH, 40
.equ SCREEN_HEIGHT, 25

# Devices
.equ RTC_BASE, 0x101000
.equ UART_BASE, 0x10000000

# Output

# Options
# 0 - framebuffer only (writes to memory, can be inspected by gdb)
# 1 - serial
# 2 - serial with framebuffer (emulates screen over serial)
# 3 - screen (graphics driver required)
# At this moment only option 1 is supported
# The option can be provided to `as` with
# `--defsym OUTPUT_DEV=1`
.ifndef OUTPUT_DEV
    .equ OUTPUT_DEV, 1
.endif
