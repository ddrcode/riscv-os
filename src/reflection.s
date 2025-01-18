# Assembly reflection library
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.include "macros.s"
.include "consts.s"

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
    mv a3, zero
    call _get_set_reg
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
    li a3, 1
    call _get_set_reg
    stack_free
    ret
endfn


# Gets or sets a value of a registry from RISC-V instruction
# Arguments
#     a0 - RISC-V instruction
#     a1 - register (0 - rd, 1 - rs1, 2 - rs2)
#     a2 - pointer to a memory (usually stack) with registers dump
#          starting from x0 (so x1 i addr+4, etc)
#     a3 - operation (0 - get, 1 - set)
# Returns
#     a0 - value from the registry
#     a5 - error code
fn _get_set_reg
    stack_alloc
    push a2, 8
    push a3, 4
    call refl_get_reg_id
    bgez a0, 1f
        li a5, ERR_INVALID_ARGUMENT
        mv a0, zero
        j 2f

1:  pop a2, 8
    pop a3, 4
    slli a0, a0, 2
    add t0, a0, a2
    bnez a3, 2f
        lw a0, (t0)
        j 3f
2:
    sw a0, (t0)
3:
    stack_free
    ret
endfn
