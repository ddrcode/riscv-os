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

    la a0, drv_uart_0                  # Configure UART0
    mv s1, a0
    li a1, UART0_BASE
    li a2, 0b11
    li a3, UART0_IRQ
    call ns16550a_init

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

.section .data.platform

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
    .word    handle_uart_irq           # IRQ 10 (UART 0)
    .word    0 /* ? */                 # IRQ 11
    .word    0 /* PCIE Root Port */    # IRQ 12
    .word    0 /* RTC */               # IRQ 13
    .word    0 /* reserved */          # IRQ 14
    .word    0 /* reserved */          # IRQ 15


#----------------------------------------

.section .data

drv_uart_0: .space DRV_UART_STRUCT_SIZE, 0

