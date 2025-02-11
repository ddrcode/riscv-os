# UART Structure
# byte    size    name
#    0       4    device id (actually UART base)
#    4       4    byte config(u32 base_addr, byte mask, byte val)
#    8       4    u32 putc(u32 base_addr, char c)
#   12       4    byte getc(u32 base_addr)
#   16       1    buffer
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
.global uart_get_config
.global uart_handle_irq


.section .text

fn uart_putc
    stack_alloc
    lw t1, 8(a0)
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
        mv a0, s0
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
    lw t1, 12(a0)
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

