.equ IO_BANK0_BASE,      0x40028000
.equ PADS_BANK0_BASE,    0x40038000
.equ ATOMIC_CLR_OFFSET,  0x3000

.equ GPIO25_CTRL,        IO_BANK0_BASE + 0x0cc
.equ GPIO25_PAD,         PADS_BANK0_BASE + 0x68

.equ GPIO_FUNC_SIO,      5
.equ PAD_ISO_BIT,        (1 << 8)

.equ SIO_BASE,           0xd0000000
.equ GPIO_OUT,           SIO_BASE + 0x010
.equ GPIO_OE,            SIO_BASE + 0x030
.equ GPIO_25,            (1 << 25)

.equ DELAY_COUNT,        5000000

.global _start

.section .text
.align 4

_start:
    # Clear GPIO25 pad isolation (RP2350-specific; not needed on RP2040)
    li a0, GPIO25_PAD + ATOMIC_CLR_OFFSET
    li a1, PAD_ISO_BIT
    sw a1, 0(a0)

    # Select SIO function for GPIO25
    li a0, GPIO25_CTRL
    li a1, GPIO_FUNC_SIO
    sw a1, 0(a0)

    # Enable output drive for GPIO25 only
    li a0, GPIO_OE
    li a1, GPIO_25
    sw a1, 0(a0)

    # Toggle pattern: s1 alternates between GPIO_25 and 0
    li s1, GPIO_25
    add t0, s1, zero
    li a0, GPIO_OUT

loop:
    sw s1, 0(a0)           # drive GPIO_OUT = s1
    li a2, DELAY_COUNT
1:  addi a2, a2, -1
    bnez a2, 1b
    xor s1, s1, t0         # flip bit 25 in s1
    j loop
