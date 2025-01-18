# Assembly reflection library
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.include "macros.s"

.global refl_get_reg_id
.global refl_get_reg
.global refl_set_reg

.section .text

# Returns registry number from an instruction
# Arguments
#     a0 - RISC-V instruction
#     a1 - register (0 - rd, 1 - rs1, 2 - rs2)
# Returns
#     a0 - registry number (0-15) or -1 in case of error
fn refl_get_reg_id
    bnez a1, 1f
0: # rd
    li t0, 7
    j 4f
1: #rs1:
    li t1, 1
    bne a1, t0, 2f
    li t0, 15
    j 4f
2: # rs2:
    li t0, 2
    bne a1, t0, 3f
    li t0, 20
    j 4f
3: # err
    li a0, -1
    j 5f
4: # read reg number
    srl t1, a0, t0
    andi a0, t1, 0b11111
    li t2, 15
    bgt a2, t2, 3b
5: # end
    ret
endfn


# Gets a value of a registry from RISC-V instruction
# Arguments
#     a0 - RISC-V instruction
#     a1 - register (0 - rd, 1 - rs1, 2 - rs2)
#     a2 - pointer to a memory (usually stack) with registers dump
#          starting from x0 (so x1 i addr+4, etc)
# Returns
#     a0 - value from the registry
#     a5 - error code
fn refl_get_reg
    stack_alloc
    push a2, 8
    call refl_get_reg_id
    pop a2, 8
    slli a0, a0, 2
    add t0, a0, a2
    lw a0, (t0)
    stack_free
    ret
endfn


# Gets a value of a registry from RISC-V instruction
# Arguments
#     a0 - RISC-V instruction
#     a1 - register (0 - rd, 1 - rs1, 2 - rs2)
#     a2 - pointer to a memory (usually stack) with registers dump
#          starting from x0 (so x1 i addr+4, etc)
# Returns
#     a0 - value from the registry
#     a5 - error code
fn refl_set_reg
    stack_alloc
    push a2, 8
    call refl_get_reg_id
    pop a2, 8
    slli a0, a0, 2
    add t0, a0, a2
    sw a0, (t0)
    stack_free
    ret
endfn

