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


.section .text

fn platform_start
    stack_alloc
    push s1, 8

    call irq_init
    call plic_init

    la a0, drv_uart_0                  # Configure UART0
    mv s1, a0
    li a1, UART0_BASE
    li a2, 0b01
    li a3, UART0_IRQ
    call sifive_uart_init

    call_cfg_set CFG_STD_OUT, s1
    call_cfg_set CFG_STD_IN, s1
    call_cfg_set CFG_STD_ERR, s1
    call_cfg_set CFG_STD_DEBUG, s1

    pop s1, 8
    stack_free
    ret
endfn

fn handle_uart_irq
    # nothing to do here, as the IRQ's are handled directly
    # by the UART's driver, however the handler must exist
    # as otherwise there is unhandled IRQ error
    ret
endfn


#----------------------------------------

.section .data

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
    .word    0                         # IRQ 10
    .word    0                         # IRQ 11
    .word    0                         # IRQ 12
    .word    0                         # IRQ 13
    .word    0                         # IRQ 14
    .word    0                         # IRQ 15


drv_uart_0: .space DRV_UART_STRUCT_SIZE, 0
drv_uart_1: .space DRV_UART_STRUCT_SIZE, 0

