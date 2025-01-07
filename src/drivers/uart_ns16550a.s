# UART "driver" for RISC-V OS
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# UART initialization and getc inspired by
# https://github.com/safinsingh/ns16550a
#
# See LICENSE for license details.

.include "config.s"
.include "macros.s"

.global uart_init
.global uart_putc
.global uart_puts
.global uart_getc

.equ LINE_STATUS_REG,           0x5
.equ LINE_CONTROL_REG,          0x3
.equ FIFO_CONTROL_REG,          0x2
.equ IRQ_ENABLE_REG,            0x1

.equ UART_LSR_DA,               0x01   # Data Available
.equ UART_LSR_OE,               0x02   # Overrun Error
.equ UART_LSR_PE,               0x04   # Parity Error
.equ UART_LSR_FE,               0x08   # Framing Error
.equ UART_LSR_BI,               0x10   # Break indicator
.equ UART_LSR_RE,               0x20   # THR is empty
.equ UART_LSR_RI,               0x40   # THR is empty and line is idle
.equ UART_LSR_EF,               0x80   # Erroneous data in FIFO

.section .text

.type uart_init, @function
uart_init:
    li t0, UART_BASE

    li t1, 0x3                         # 0x3 -> 8 bit word length
    sb t1, LINE_CONTROL_REG(t0)

    li t1, 0x1                         # 0x1 -> enable FIFOs
    sb t1, LINE_CONTROL_REG(t0)

    sb t1, IRQ_ENABLE_REG(t0)     # 0x1 -> enable reciever interrupts

    ret


# a0 - String address
.type puts, @function
uart_puts:
    beqz a0, 2f
    li a1, UART_BASE
1:                                     # While string byte is not null
    lbu t0, (a0)                        # Get byte at current string pos
    beq zero, t0, 3f                   # Is null?
    sb t0, (a1)                        # No, write byte to port
    inc a0                             # Inc string pos
    j 1b                               # Loop
2:                                     # String byte is null
    li a0, 2                           # Set error code
    j 4f
3:  setz a0                            # Set exit code
4:  ret


# prints a single character to the screen
# a0 - char code
.type putc, @function
uart_putc:
    li t0, UART_BASE

1:  lbu t1, LINE_STATUS_REG(t0)        # Loop until the line is idle and THR empty
        andi t1, t1, UART_LSR_RI
        beqz t0, 1b

    andi t1, a0, 0xff                  # Ensure the parameter is a byte
    sb t1, (t0)                        # Send byte to UART
    ret


.type uart_get, @function
uart_getc:
    li t0, UART_BASE

    lbu t1, LINE_STATUS_REG(t0)
    andi t1, t1, UART_LSR_DA

    bnez t1, 1f                        # jump if UART is ready to read from
        mv a0, zero                    # otherwise, return 0
        j 2f
1:
    lbu a0, (t0)                       # load character at UART address
2:  ret


