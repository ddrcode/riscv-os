# Platform startup
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "macros.s"
.include "config.s"
.include "consts.s"

.global platform_start
.global external_irq_vector


.section .text.platform

fn platform_start
    stack_alloc
    push s1, 8

    call irq_init
    call plic_init

    li a0, 1
    # call uart_init

    la a0, drv_uart_0
    mv s1, a0
    li a1, UART_BASE
    li a2, 0b11
    call ns16550a_init

    li a0, CFG_STD_OUT
    mv a1, s1
    call cfg_set

    li a0, CFG_STD_IN
    mv a1, s1
    call cfg_set

    pop s1, 8
    stack_free
    ret
endfn

.section .data.platform


# This is platform / machine - specific
.align 4
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

.section .data
drv_uart_0: .space 16, 0

