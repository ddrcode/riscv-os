# UART "driver" for RISC-V OS
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# UART initialization and getc inspired by
# https://github.com/safinsingh/ns16550a
#
# See LICENSE file for license details.

.include "config.s"
.include "macros.s"

# dont expose more function from this file!
.global ns16550a_init

.equ IER,                       0x1    # Interrupt enable register
.equ IIR,                       0x2    # Interrupt identification register
.equ LCR,                       0x3    # Line Control Register
.equ MCR,                       0x4    # Modem Control Register
.equ LSR,                       0x5    # Line staus register

.equ UART_LSR_DA,               0x01   # Data Available
.equ UART_LSR_OE,               0x02   # Overrun Error
.equ UART_LSR_PE,               0x04   # Parity Error
.equ UART_LSR_FE,               0x08   # Framing Error
.equ UART_LSR_BI,               0x10   # Break indicator
.equ UART_LSR_RE,               0x20   # THR is empty
.equ UART_LSR_RI,               0x40   # THR is empty and line is idle
.equ UART_LSR_EF,               0x80   # Erroneous data in FIFO

.section .text

# Arguments
#     a0 - pointer to uart driver structure
#     a1 - base address
#     a2 - initial config
#     a3 - IRQ id
fn ns16550a_init

    .set BASE, 0
    .set GETC, 8
    .set PUTC, 12
    .set CONFIG_FN, 4

    stack_alloc
    push a2, 8
    push a1, 4
    push a0, 0

    # UART record

    sw a1, BASE(a0)                    # save device id (that is base addr)

    la t0, ns16550a_putc               # pointer to putc
    sw t0, GETC(a0)

    la t0, ns16550a_getc               # pointer to getc
    sw t0, PUTC(a0)

    la t0, ns16550a_config             # pointer to config
    sw t0, CONFIG_FN(a0)

    mv a0, a1
    mv a1, a3
    call ns16550a_start                # start/initialize the device with default settings

    pop a0, 4
    not a1, zero
    pop a2, 8
    call ns16550a_config               # configure uart

    pop a0, 0                          # return structure pointer
    stack_free
    ret
endfn


# Arguments
#     a0 - UART base
#     a1 - IRQ id
fn ns16550a_start
    stack_alloc
    mv t0, a0

    li t1, 0x3                         # 0x3 -> 8 bit word length
    sb t1, LCR(t0)

    li t1, 1                           # 0x1 -> enable FIFOs
    sb t1, LCR(t0)

    sb zero, IER(t0)                   # don't enable reciever interrupts by default

    li t1, 0b1000
    sb t1, MCR(t0)                     # Enable OUT2

.ifdef PLIC_BASE
    mv a0, a1                          # configure PLIC IRQ
    li a1, 1
    call plic_enable_irq
.endif

    stack_free
    ret
endfn


# Signature: void ns16550a_putc(u32 id, char c)
# Arguments
#     a0 - base address
#     a1 - character to print
# Returns: same as input
fn ns16550a_putc
1:
    lbu t1, LSR(a0)                    # Loop until the line is idle and THR empty
        andi t1, t1, UART_LSR_RI
        beqz t1, 1b

    andi t1, a1, 0xff                  # Ensure the parameter is a byte
    sb t1, (a0)                        # Send byte to UART
    ret
endfn


# Signature: char ns16550a_getc(u32 id)
# Arguments
#     a0 - base address
# Returns:
#     a0 - char (zero if none)
fn ns16550a_getc
    mv t0, a0
    mv a0, zero                        # set the default result

    lbu t1, IER(t0)                    # check whether interupts are on
    bnez t1, 1f                        # jump if so

    # reading from UART directly

    lbu t1, LSR(t0)                    # read byte from control register
    andi t1, t1, UART_LSR_DA           # and check "data available" flag

    bnez t1, 2f                        # jump if UART is ready to read from
        j 3f                           # finish otherwise

1:  # reading from IRQ buffer

    li t2, 4                           # 4 = Received Data Available
    lbu t1, IIR(t0)                    # Read UART IIR to check interrupt type
    andi t1, t1, 0x0f                  # Mask interrupt ID
    bne t1, t2, 3f                     # Exit if no data

2:
    lbu a0, (t0)                       # read byte from UART

3:
    ret
endfn


# Signature: byte ns16550a_config(u32 id, byte mask, byte config)
# Arguments
#     a0 - base addr
#     a1 - mask
#     a2 - config
# Returns:
#     a0 - new config
#
# TODO Handle IRQs for outgoing data (bit 0b100)
# TODO handle enabling/disabling device (bit 1)
fn ns16550a_config
    mv a3, a0                          # load UART's base address
    beqz a1, 1f                        # just return the config if mask is 0

.ifdef PLIC_BASE                       # no point enabling IRQ if PLIC is not present
    andi t0, a1, 0b10
    beqz t0, 1f                        # should input IRQ be configured?

        andi t0, a2, 0b10
        srli t0, t0, 1
        sb t0, IER(a3)                 # 1 -> enable reciever interrupts

    # FIXME check for other flags

.endif

1:
    li a0, 1                           # 'Enabled' flag is always on

    lbu t0, IER(a3)                    # Read receiver IRQ flag
    snez t0, t0
    slli t0, t0, 1
    or a0, a0, t0

    ret
endfn

