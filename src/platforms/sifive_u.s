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

    la a0, uart_0_buffer
    li a1, 8
    la a2, uart_0_buffer_data
    call buff_init

    la a0, uart_1_buffer
    li a1, 8
    la a2, uart_1_buffer_data
    call buff_init

    la a0, drv_uart_0                  # Configure UART0
    li a1, UART_0_BASE
    li a2, 0b11                        # Enable device and IRQ
    li a3, UART_0_IRQ
    la a4, uart_0_buffer
    call sifive_uart_init
    mv s1, a0

    call_cfg_set CFG_STD_OUT, s1
    call_cfg_set CFG_STD_IN, s1
    call_cfg_set CFG_STD_ERR, s1


    la a0, drv_uart_1                  # Configure UART1
    li a1, UART_1_BASE
    li a2, 0b01                        # Enable device without IRQs
    li a3, UART_1_IRQ
    la a4, uart_1_buffer
    call sifive_uart_init
    mv s1, a0

    call_cfg_set CFG_STD_DEBUG, s1


    add_device DEV_UART_0, drv_uart_0  # add devices to device manager
    add_device DEV_UART_1, drv_uart_1


    la s1, platform_name
    call_cfg_set CFG_PLATFORM_NAME, s1

    pop s1, 8
    stack_free
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
    .word    uart_handle_irq           # IRQ  4
    .word    uart_handle_irq           # IRQ  5
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


drv_uart_0:          .space DRV_UART_STRUCT_SIZE, 0
drv_uart_1:          .space DRV_UART_STRUCT_SIZE, 0

uart_0_buffer:       .space 12, 0
uart_0_buffer_data:  .space 8, 0

uart_1_buffer:       .space 12, 0
uart_1_buffer_data:  .space 8, 0

#----------------------------------------

.section .rodata

platform_name: .string "sifive_u"
