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
.global uart_get_status
.global uart_handle_irq

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

# Initialies the UART
# Arguments:
#     a0 - 1 to enable IRQs, 0 otherwise
.type uart_init, @function
uart_init:
    stack_alloc
    li t0, UART_BASE

    li t1, 0x3                         # 0x3 -> 8 bit word length
    sb t1, LCR(t0)

    li t1, 1                           # 0x1 -> enable FIFOs
    sb t1, LCR(t0)

    sb a0, IER(t0)                     # 0x1 -> enable reciever interrupts

    li t1, 0b1000
    sb t1, MCR(t0)                     # Enable OUT2

    li a0, UART_IRQ                    # configure PLIC IRQ
    li a1, 1
    call plic_enable_irq

    stack_free
    ret


# prints a single character to the screen
# a0 - char code
.type putc, @function
uart_putc:
    li t0, UART_BASE

1:  lbu t1, LSR(t0)                    # Loop until the line is idle and THR empty
        andi t1, t1, UART_LSR_RI
        beqz t1, 1b

    andi t1, a0, 0xff                  # Ensure the parameter is a byte
    sb t1, (t0)                        # Send byte to UART
    ret


# a0 - String address
.type puts, @function
uart_puts:
    stack_alloc
    push s0, 8
    beqz a0, 2f                        # Null address - error
    mv s0, a0
1:                                     # While string byte is not null
    lbu a0, (s0)                       # Get byte at current string pos
    beqz a0, 3f                        # Is null?
        call uart_putc                 # No, write byte to port
        inc s0                         # Inc string pos
        j 1b                           # Loop
2:                                     # String byte is null
    li a0, 2                           # Set error code
    j 4f
3:  setz a0                            # Set exit code
4:  pop s0, 8
    stack_free
    ret


.type uart_get, @function
uart_getc:
    li t0, UART_BASE

    lbu t1, IER(t0)                    # check whether interupts are on
    bnez t1, 2f                        # jump if so

    # Read byte from UART
    lbu t1, LSR(t0)
    andi t1, t1, UART_LSR_DA

    bnez t1, 1f                        # jump if UART is ready to read from
        mv a0, zero                    # otherwise, return 0
        j 3f
1:
    lbu a0, (t0)                       # load character at UART address
    j 3f

2:  # read from buffer rather than from UART itself (value set by irq)
    la t0, uart_buffer
    lbu a0, (t0)
    sb zero, (t0)

3:  ret


.type uart_handle_irq, @function
uart_handle_irq:
    stack_alloc

    li t0, UART_BASE
    lbu t1, IIR(t0)                    # Read UART IIR to check interrupt type
    andi t1, t1, 0x0f                  # Mask interrupt ID

    li t2, 4                           # 0x4 = Received Data Available
    bne t1, t2, 1f
        lbu a0, 0(t0)                  # Read received byte to clear the interrupt
        la t0, uart_buffer             # and store in the buffer
        sb a0, (t0)

    # beq t1, 0x2, tx_ready # 0x2 = Transmitter Empty
1:
    stack_free
    ret


uart_get_status:
    mv a0, zero
    li t0, UART_BASE

    lbu t1, IER(t0)                    # check whether interupts are on
    snez t1, t1                        # set t1 to 1 if so
    or a0, a0, t1

    ret


#----------------------------------------

.section .data

uart_buffer: .byte 0
