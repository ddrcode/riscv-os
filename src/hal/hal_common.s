# Common functions for all HAL drivers
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.include "macros.s"

.global hal_get_config
.global hal_set_config

.section .text

fn hal_get_config
    stack_alloc
    mv a1, zero
    mv a2, zero
    lw t1, 4(a0)
    jalr t1
    stack_free
    ret
endfn


# Set's driver's configuration
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
fn hal_set_config
    stack_alloc
    lw t1, 4(a0)
    jalr t1
    stack_free
    ret
endfn

