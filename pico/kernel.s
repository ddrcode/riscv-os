.equ GPIO_BASE,  0x40014000  # Base address of GPIO
.equ GPIO_CTRL,  0x40014004  # GPIO control register
.equ GPIO_OE,    0x40014020  # Output enable register
.equ GPIO_OUT,   0x40014010  # Output register
.equ GPIO_25,    (1 << 25)   # GPIO 25 bitmask
.equ DELAY_COUNT, 1000000    # Delay loop count

.global _start

.section .text
.align 4
_start:
    la gp, __global_pointer$           # initialize global pointer, see:
                                       # https://www.five-embeddev.com//quickref/global_pointer.html
    la sp, __stack_top                 # initialize stack pointer
    mv s0, sp

    # Enable GPIO 25 as output
    li a0, GPIO_OE
    lw a1, 0(a0)        # Read current output enable state
    li t0, GPIO_25
    or a1, a1, t0       # Set GPIO 25 as output
    sw a1, 0(a0)        # Write back to output enable register

loop:
    # Toggle GPIO 25
    li a0, GPIO_OUT
    lw a1, 0(a0)        # Read current GPIO output
    xor a1, a1, t0      # Toggle GPIO 25 bit
    sw a1, 0(a0)        # Write back

    # Delay loop
    li a2, DELAY_COUNT
delay:
    addi a2, a2, -1
    bnez a2, delay      # Keep looping until delay expires

    j loop              # Repeat blinking


