.equ IO_BANK0_BASE,      0x40028000
.equ PADS_BANK0_BASE,    0x40038000

.equ GPIO25_CTRL,        IO_BANK0_BASE + 0x0cc
.equ GPIO25_PAD,         PADS_BANK0_BASE + 0x68

.equ GPIO_FUNC_SIO,      5

.equ SIO_BASE,           0xd0000000
.equ GPIO_OUT_SET,       SIO_BASE + 0x014
.equ GPIO_OUT_CLR,       SIO_BASE + 0x018
.equ GPIO_OE_SET,        SIO_BASE + 0x024

.equ GPIO_25,            0x02000000
.equ DELAY_COUNT,        50000000

.global _start

.section .text
.align 4

_start:
    la gp, __global_pointer$
    la sp, __stack_top
    mv s0, sp

    # Match:
    # set {int}0x40038068 = 0x00000000
    li a0, GPIO25_PAD
    li a1, 0
    sw a1, 0(a0)

    # Match:
    # set {int}0x400280cc = 5
    li a0, GPIO25_CTRL
    li a1, GPIO_FUNC_SIO
    sw a1, 0(a0)

    # Match:
    # set {int}0xd0000030 = 0x02000000
    li a0, GPIO_OE_SET
    li a1, GPIO_25
    sw a1, 0(a0)

loop:
    # LED on
    li a0, GPIO_OUT_SET
    li a1, GPIO_25
    sw a1, 0(a0)

    li a2, DELAY_COUNT
delay_on:
    addi a2, a2, -1
    bnez a2, delay_on

    # LED off
    li a0, GPIO_OUT_CLR
    li a1, GPIO_25
    sw a1, 0(a0)

    li a2, DELAY_COUNT
delay_off:
    addi a2, a2, -1
    bnez a2, delay_off

    j loop
