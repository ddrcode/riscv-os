# Platform startup
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "macros.s"
.include "config.s"
.include "consts.s"

.global platform_start
.global setup_pmp
.global external_irq_vector


.section .text

fn platform_start
    stack_alloc
    push s1, 8

    call irq_init
    call plic_init

    la a0, drv_uart_0                  # Configure UART0
    mv s1, a0
    li a1, UART_0_BASE
    li a2, 0b01
    li a3, UART_0_IRQ
    call sifive_uart_init

    call_cfg_set CFG_STD_OUT, s1
    call_cfg_set CFG_STD_IN, s1
    call_cfg_set CFG_STD_ERR, s1

    la a0, drv_uart_1                  # Configure UART1
    mv s1, a0
    li a1, UART_1_BASE
    li a2, 0b01
    li a3, UART_1_IRQ
    call sifive_uart_init

    call_cfg_set CFG_STD_DEBUG, s1

    add_device DEV_UART_0, drv_uart_0  # add devices to device manager
    add_device DEV_UART_1, drv_uart_1


    la s1, platform_name
    call_cfg_set CFG_PLATFORM_NAME, s1

    pop s1, 8
    stack_free
    ret
endfn


# Custom config of PMP specific for sifive_e
# It overrides the config from system.s
# as it must additionally configure the ROM
fn setup_pmp
    li t0, (ROM_START_ADDR / 2) >> 2   # region 0 - addresses before ROM
    csrw pmpaddr0, t0

    li t0, (ROM_START_ADDR + (ROM_END_ADDR - ROM_START_ADDR) / 2) >> 2
    csrw pmpaddr1, t0                  # region 1 - ROM

    li t0, (RAM_START_ADDR / 2) >> 2   # region 2 - addresses between ROM and RAM
    csrw pmpaddr2, t0

    li t0, (RAM_START_ADDR + (RAM_END_ADDR - RAM_START_ADDR) / 2) >> 2
    csrw pmpaddr3, t0                  # region 3 - RAM

    not t0, zero                       # region 4 - everything above RAM up to 0xffffffff
    csrw pmpaddr4, t0

    li t2, 0b11100                     # Make pre-RAM accessible to machine mode only

    li t0, 0b11101                     # ROM: give RX rights to user mode
    slli t1, t0, 8
    or t2, t2, t1

    li t0, 0b01100                     # post-ROM: access reserved to Machine only
    slli t1, t0, 16
    or t2, t2, t1

    li t0, 0b11111                     # RAM: give RWX rights to user mode
    slli t1, t0, 24
    or t2, t2, t1

.if PMP_LOCKED > 0                     # If locking is enabled set bit 7 to 1 for
    li t0, 0x80808080                  # all regions
    or t2, t2, t0
.endif

    csrw pmpcfg0, t2                   # save permissions

    li t2, 0b01100                     # Make post-RAM accessible to machine mode only
.if PMP_LOCKED > 0                     # If locking is enabled set bit 7 to 1
    li t0, 0x80
    or t2, t2, t0
.endif

    csrw pmpcfg1, t2                   # save permissions
    ret
endfn


#----------------------------------------

.section .data

# This is platform / machine - specific
external_irq_vector:
    .word    0                         # IRQ  0
    .word    0                         # IRQ  1
    .word    0                         # IRQ  2
    .word    uart_handle_irq           # IRQ  3
    .word    uart_handle_irq           # IRQ  4
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


#----------------------------------------

.section .rodata

platform_name: .string "sifive_e"
