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
    li t0, UART_BASE

    li t1, UART_REG_IE                 # disable interrupts
    add t1, t0, t1
    sw zero, (t1)

    li t1, UART_REG_TXCTRL             # enable tx
    add t1, t0, t1
    li t2, UART_TXCTRL_TXEN
    sw t2, (t1)

    li t1, UART_REG_RXCTRL             # enable rx
    add t1, t0, t1
    li t2, UART_RXCTRL_RXEN
    sw t2, (t1)

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


fn uart_getc
    mv a0, zero
    li t0, UART_BASE

    lw t1, UART_REG_RXFIFO(t0)
    li t2, UART_RXFIFO_EMPTY
    and t2, t1, t2
    bnez t2, 1f
        li t2, UART_RXFIFO_DATA
        and a0, t1, t2
1:  ret
endfn


fn uart_handle_irq
    ret
endfn

