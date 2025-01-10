.include "macros.s"
.include "config.s"

.global uart_init
.global uart_putc
.global uart_puts
.global uart_getc
.global uart_handle_irq

.equ UART_REG_TXFIFO,	0
.equ UART_REG_RXFIFO,	4
.equ UART_REG_TXCTRL,	8
.equ UART_REG_RXCTRL,	12
.equ UART_REG_IE,    	16
.equ UART_REG_IP,	    20
.equ UART_REG_DIV,      24

.equ UART_TXFIFO_FULL,	0x80000000
.equ UART_RXFIFO_EMPTY,	0x80000000
.equ UART_RXFIFO_DATA,	0x000000ff
.equ UART_TXCTRL_TXEN,	0x1
.equ UART_RXCTRL_RXEN,	0x1

.section .text


fn uart_init
    stack_alloc
    li t0, UART_BASE

    li t1, UART_REG_IE                 # enable interrupts for receive
    add t1, t0, t1
    li t2, 1
    sw t2, (t1)

    li t1, UART_REG_TXCTRL             # enable tx
    add t1, t0, t1
    li t2, UART_TXCTRL_TXEN
    sw t2, (t1)

    li t1, UART_REG_RXCTRL             # enable rx
    add t1, t0, t1
    li t2, UART_RXCTRL_RXEN
    sw t2, (t1)

    li a0, UART_IRQ
    li a1, 1
    call plic_enable_irq

    stack_free
    ret
endfn


# prints a single character to the screen
# a0 - char code
fn uart_putc
    li t0, UART_BASE
1:
    lw t1, UART_REG_TXFIFO(t0)
    li t2, UART_TXFIFO_FULL
    and t2, t1, t2
    bnez t2, 1b

    sw a0, UART_REG_TXFIFO(t0)

    ret
endfn


# a0 - String address
fn uart_puts
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
endfn


fn uart_getc
    li t0, UART_BASE

    lw t1, UART_REG_IE(t0)             # check if irq is enabled
    beqz t1, uart                      # jump if not

irq:
    la t1, uart_buffer
    lbu a0, (t1)
    sb zero, (t1)
    j 1f

uart:
    mv a0, zero
    lw t1, UART_REG_RXFIFO(t0)
    li t2, UART_RXFIFO_EMPTY
    and t2, t1, t2
    bnez t2, 1f
        li t2, UART_RXFIFO_DATA
        and a0, t1, t2

1:
    ret
endfn


fn uart_handle_irq
    stack_alloc
    # UART Base Address
    li t0, UART_BASE

    # Read the ip register to check interrupt cause
    lw t1, 0x14(t0)          # Load ip register

    # Check for RX interrupt (bit 1)
    andi t2, t1, 0x2         # Mask RX interrupt bit
    bnez t2, rx_interrupt    # Jump if RX interrupt is pending

    # Check for TX interrupt (bit 0)
    andi t2, t1, 0x1         # Mask TX interrupt bit
    bnez t2, tx_interrupt    # Jump if TX interrupt is pending

    # No UART interrupt
    j done

rx_interrupt:
    # Read received data from rxdata register
    lw t1, 0x04(t0)          # Load rxdata register
    andi t2, t1, 0xFF        # Mask to extract received byte (8 bits)

    la t1, uart_buffer
    sb t2, (t1)
    # Process the received byte (e.g., store in a buffer or print it)
    # For simplicity, let's assume you output it back (echo)
    # sw t2, 0x00(t0)          # Write the byte back to txdata for echoing

    j done

tx_interrupt:
    # Handle TX interrupt (e.g., load next byte to send)
    # For simplicity, we'll send a test character ('A')
    # li t5, 'A'               # Load ASCII value of 'A'
    # sw t5, 0x00(t0)          # Write to txdata register to send
    # la t1, uart_buffer
    # li t2, 'S'
    # sb t2, (t1)

    j done

done:
    ret                      # Return to the main IRQ handler
endfn

.section .data

uart_buffer: .byte 0
