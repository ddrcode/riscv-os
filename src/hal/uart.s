# UART Structure
# byte    size    name
#    0       4    device id (actually UART base)
#    4       4    u32 putc(u32 base_addr, char c)
#    8       4    byte getc(u32 base_addr)
#   12       4    byte config(u32 base_addr, byte mask, byte val)
#
# Configuration
#  bit     name
#    0     uart enabled
#    1     input irq enabled
#    2     output irq enabled


.include "macros.s"


.global uart_putc
.global uart_puts
.global uart_getc
.global uart_handle_irq


.section .text

fn uart_putc
    stack_alloc
    mv t0, a0
    lw a0, (t0)
    lw t1, 4(t0)
    jalr t1
    stack_free
    ret
endfn

# Arguments:
#     a0 - pointer to uart structure
#     a1 - pointer to a string
fn uart_puts
    stack_alloc
    push s0, 8
    push s1, 4

    beqz a1, 2f                        # Null address - error
    mv s0, a0
    mv s1, a1

1:                                     # While string byte is not null
    mv a0, s0
    lbu a1, (s1)                       # Get byte at current string pos
    beqz a1, 3f                        # Is null?
        lw t1, 4(s0)
        call uart_putc                 # No, write byte to port
        inc s1                         # Inc string pos
        j 1b                           # Loop
2:                                     # String byte is null
    li a0, 2                           # Set error code
    j 4f
3:  setz a0                            # Set exit code
4:  pop s0, 8
    pop s1, 4
    stack_free
    ret
endfn

fn uart_getc
    stack_alloc
    mv t0, a0
    lw a0, (t0)
    lw t1, 8(t0)
    jalr t1
    stack_free
    ret
endfn

# Returns configuration
# Arguments: a0 - pointer to uart structure
# Returns: a0 - configuration
fn uart_get_config
    stack_alloc
    mv t0, a0
    lw a0, (t0)
    mv a1, zero
    mv a2, zero
    lw t1, 12(t0)
    jalr t1
    stack_free
    ret
endfn

# Returns configuration
# Example (enabling uart, but disabling IRQs)
#    la a0, UART0
#    li a1, 0b11
#    li a2, 0b01
#    call uart_set_config
# Arguments:
#     a0 - pointer to uart structure
#     a1 - configuration mask
#     a2 - configuration flags
# Returns: a0 - new configuration
fn uart_set_config
    stack_alloc
    mv t0, a0
    lw a0, (t0)
    lw t1, 12(t0)
    jalr t1
    stack_free
    ret
endfn


fn uart_handle_irq
    # nothing to do here, as the IRQ's are handled directly
    # by UART drivers, however the handler must exist
    # as otherwise there is unhandled IRQ error
    ret
endfn

