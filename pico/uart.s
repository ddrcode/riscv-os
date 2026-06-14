# see page 967
.equ UART_BASE, 0x40070000
.equ UARTCR, 0x30                      # control register

.global _start

.section .text
.align 4

_start:

    li t0, UART_BASE
    addi t1, t0, UARTCR
    li t2, 512                         # set bits 8 and 9 (enable tr and tx)
    sh t2, (t1)

    li a0, 65
    li a1, UART_BASE
    sw a0, 0(a1)
    wfi
