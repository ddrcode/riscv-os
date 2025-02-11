.include "macros.s"
.include "config.s"

.global sifive_uart_init

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

# Arguments
#     a0 - pointer to uart driver structure
#     a1 - base address
#     a2 - initial config
#     a3 - IRQ id
#     a4 - buffer pointer
fn sifive_uart_init
    .set BASE, 0
    .set CONFIG_FN, 4
    .set PUTC, 8
    .set GETC, 12
    .set IRQ_FN, 16
    .set BUFF_ADDR, 20

    stack_alloc
    push a2, 8
    push a1, 4
    push a0, 0

    # UART record

    sw a1, BASE(a0)                    # save device id (that is base addr)
    sw a4, BUFF_ADDR(a0)               # save UART's buffeer address

    la t0, sifive_uart_putc            # pointer to putc
    sw t0, PUTC(a0)

    la t0, sifive_uart_getc            # pointer to getc
    sw t0, GETC(a0)

    la t0, sifive_uart_config          # pointer to config
    sw t0, CONFIG_FN(a0)

    la t0, sifive_uart_irq_handler
    sw t0, IRQ_FN(t0)

    mv a0, a1
    mv a1, a3
    call sifive_uart_start             # start/initialize the device with default settings

    pop a0, 4
    li a1, ~0
    pop a2, 8
    call sifive_uart_config            # configure uart

    pop a0, 0                          # return structure pointer
    stack_free
    ret
endfn


# Arguments:
#     a0 - base addr
#     a1 - irq id
fn sifive_uart_start
    stack_alloc
    mv t0, a0

    li t1, UART_REG_IE                 # disable interrupts for receive
    add t1, t0, t1                     # by default
    sw zero, (t1)

    li t1, UART_REG_TXCTRL             # enable tx
    add t1, t0, t1
    li t2, UART_TXCTRL_TXEN
    sw t2, (t1)

    li t1, UART_REG_RXCTRL             # enable rx
    add t1, t0, t1
    li t2, UART_RXCTRL_RXEN
    sw t2, (t1)

.ifdef PLIC_BASE
    mv a0, a1                          # sets up PLIC with UART's IRQ (it doesn't enable IRQs)
    li a1, 1                           # IRQ priority
    call plic_enable_irq
.endif

    stack_free
    ret
endfn


# Outputs single character to the device
# Arguments
#     a0 - self (UARTDriver structure)
#     a1 - character to print
# Returns: same as input
fn sifive_uart_putc
    lw a0, (a0)                        # Load BASE_ADDR
1:
    lw t1, UART_REG_TXFIFO(a0)
    li t2, UART_TXFIFO_FULL
    and t2, t1, t2
    bnez t2, 1b

    # andi t1, a1, 0xff                # Ensure the parameter is a byte
    mv t1, a1
    sw t1, UART_REG_TXFIFO(a0)

    ret
endfn



# Reads a single byte from the device
# Arguments
#     a0 - self (UARTDriver structure)
# Returns:
#     a0 - char (zero if none)
fn sifive_uart_getc
    stack_alloc
    lw t0, (a0)

    lw t1, UART_REG_IE(t0)             # check if irq is enabled
    bgtz t1, 2f                        # jump is so

1:
    li a0, -1
    lw t1, UART_REG_RXFIFO(t0)
    li t2, UART_RXFIFO_EMPTY
    and t2, t1, t2
    bnez t2, 3f
        li t2, UART_RXFIFO_DATA
        and a0, t1, t2
    j 3f

2:
    lw a0, 20(t0)
    call buff_read

3:
    stack_free
    ret
endfn


# Arguments
#     a0 - self (UARTDriver structure)
#     a1 - mask
#     a2 - config
# Returns:
#     a0 - new config
fn sifive_uart_config
    lw a0, (a0)                        # load BASE_ADDR
    beqz a1, 1f                        # if mask is 0, then just read the config

    # set the config
.ifdef PLIC_BASE                       # no point enabling IRQ if PLIC is not present
    andi t0, a1, 0b10
    beqz t0, 1f                        # should input IRQ be configured?

        andi t0, a2, 0b10
        srli t0, t0, 1
        sw t0, UART_REG_IE(a0)         # check if irq is enabled
.endif


    # get the config
1:
    mv t0, a0
    li a0, 1                           # Set "enabled" bit  (FIXME don't hardcode it)

    lw t1, UART_REG_IE(t0)             # check if irq is enabled
    snez t1, t1                        # set t1 to 1 if so
    slli t1, t1, 1                     # IRQ flag is bit 1 - shift
    or a0, a0, t1

    ret
endfn


# Arguments
#     a0 - self (UARTDriver structure)
fn sifive_uart_irq_handler
    stack_alloc
    lw t0, (a0)                        # UART_BASE

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
    addi a0, a0, 20                    # Load buffer address
    lw a1, 0x04(t0)                    # Load rxdata register
    andi a1, t1, 0xff                  # Mask to extract received byte (8 bits)
    call buff_write                    # Write to buffer

    j done

tx_interrupt:
    # Handle TX interrupt (e.g., load next byte to send)
    # For simplicity, we'll send a test character ('A')
    # li t5, 'A'               # Load ASCII value of 'A'
    # sw t5, 0x00(t0)          # Write to txdata register to send
    # la t1, sifive_uart_buffer
    # li t2, 'S'
    # sb t2, (t1)

    j done

done:
    stack_free
    ret
endfn
