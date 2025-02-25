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

#----------------------------------------

.section .text.platform

fn platform_start
    stack_alloc
    push s1, 8

    call irq_init
    call plic_init

    la a0, uart_0_buffer
    li a1, 8
    call buff_init

    la a0, drv_uart_0                  # Configure UART0
    mv s1, a0
    li a1, UART0_BASE
    li a2, 0b11
    li a3, UART0_IRQ
    la a4, uart_0_buffer
    call ns16550a_init

    call_cfg_set CFG_STD_OUT, s1
    call_cfg_set CFG_STD_IN, s1
    call_cfg_set CFG_STD_ERR, s1
    call_cfg_set CFG_STD_DEBUG, s1


    la a0, drv_rtc_0                   # configure GoldFish RTC
    li a1, RTC_BASE
    call goldfish_rtc_init


    add_device DEV_UART_0, drv_uart_0  # add devices to device managet
    add_device DEV_RTC_0, drv_rtc_0


    la s1, platform_name
    call_cfg_set CFG_PLATFORM_NAME, s1

    pop s1, 8
    stack_free
    ret
endfn


fn _virt_uart_0_irq_handler
    stack_alloc

    la a0, drv_uart_0
    lw t0, 16(a0)
    jalr t0

    stack_free
    ret
endfn


#----------------------------------------

.section .data

# This is platform / machine - specific
# Provided devices are TBC
.align 4
external_irq_vector:
    .word    0                         # IRQ  0
    .word    0 /* user defined */      # IRQ  1
    .word    0 /* user defined */      # IRQ  2
    .word    0 /* keyboard / mouse */  # IRQ  3
    .word    0 /* keyboard / mouse */  # IRQ  4
    .word    0 /* block device */      # IRQ  5
    .word    0 /* network device */    # IRQ  6
    .word    0 /* console device */    # IRQ  7
    .word    0 /* RNG - random nums */ # IRQ  8
    .word    0 /* balloon device */    # IRQ  9
    .word    _virt_uart_0_irq_handler  # IRQ 10 (UART 0)
    .word    0 /* ? */                 # IRQ 11
    .word    0 /* PCIE Root Port */    # IRQ 12
    .word    0 /* RTC */               # IRQ 13
    .word    0 /* reserved */          # IRQ 14
    .word    0 /* reserved */          # IRQ 15


drv_uart_0:    .space DRV_UART_STRUCT_SIZE, 0
drv_rtc_0:     .space DRV_RTC_STRUCT_SIZE, 0

uart_0_buffer:       .space 12, 0
uart_0_buffer_data:  .space 16, 0

#----------------------------------------

.section .rodata

platform_name: .string "virt"
