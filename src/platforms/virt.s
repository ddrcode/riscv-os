# Platform startup
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "macros.s"
.include "config.s"

.global platform_start
.global external_irq_vector


.section .text.platform

fn platform_start
    stack_alloc
    call irq_init
    call plic_init

    li a0, 1
    call uart_init
    stack_free
    ret
endfn

.section .data.platform

drv_uart_0: .space 4*8

# This is platform / machine - specific
external_irq_vector:
    .word    0                         # IRQ  0
    .word    0                         # IRQ  1
    .word    0                         # IRQ  2
    .word    0                         # IRQ  3
    .word    0                         # IRQ  4
    .word    0                         # IRQ  5
    .word    0                         # IRQ  6
    .word    0                         # IRQ  7
    .word    0                         # IRQ  8
    .word    0                         # IRQ 19
    .word    uart_handle_irq           # IRQ 10
    .word    0                         # IRQ 11
    .word    0                         # IRQ 12
    .word    0                         # IRQ 13
    .word    0                         # IRQ 14
    .word    0                         # IRQ 15
