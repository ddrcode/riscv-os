# Generic driver for
# Platform-Level Interrupt Controller (PLIC)
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "macros.s"
.include "config.s"

.global plic_init
.global plic_set_treshold
.global plic_enable_irq
.global plic_get_source_id
.global plic_complete


.equ ENABLE_REGISTER,     0x2000
.equ CLAIM_REGISTER,      0x200004
.equ TRESHOLD_REGISTER,   0x200000

.section .text


.type plic_init, @function
plic_init:
    stack_alloc
    li a0, 0
    call plic_set_treshold
    stack_free
    ret


# Set PLIC treshold that defines the minimum priority
# an interrupt must have to be delivered to the CPU.
# The default and minimum treshold is 0 - means all IRQs are delivered.
# The maximum treshold is 7 - it blocks all IRQs.
# The treshold is being set per hart. This function defaults
# to hart 0.
# The algorithm is: PLIC_BASE+TRESHOLD_REGISTER+(0x1000 * heart)
# Arguments:
#    a0 - treshold
.type plic_set_treshold, @function
plic_set_treshold:
    li t0, PLIC_BASE
    li t2, TRESHOLD_REGISTER
    add t2, t0, t2
    sw a0, (t2) # Set threshold for hart 0
    ret


# Enables IRQ
# The priority is set in BASE_ADDRESS + (4*ID)
# Arguments
#     a0 - IRQ id
#     a1 - priority
.type plic_enable_irq, @function
plic_enable_irq:
    li t0, PLIC_BASE
    li t1, 4
    mul t1, t1, a0
    add t1, t1, t0
    sw a1, (t1)                        # Write to priority for source 10

    li t1, 1                           # Enable source (IRQ)
    sll t1, t1, a0
    li t2, ENABLE_REGISTER
    add t2, t0, t2
    sw t1, (t2)                        # Enable in PLIC enable register

    ret


# Returns IRQ id
# Arguments: none
# Returns: IRQ id in a0
.type plic_get_source_id, @function
plic_get_source_id:
    li t0, PLIC_BASE
    li t1, CLAIM_REGISTER
    add t1, t1, t0
    lw a0, (t1)
    ret


# Marks IRQ processing as complete
# Arguments:
#     a0: IRQ id
# Returns: IRQ id
.type plic_complete, @function
plic_complete:
    li t0, PLIC_BASE
    li t1, CLAIM_REGISTER
    add t1, t1, t0
    sw a0, (t1)
    ret
