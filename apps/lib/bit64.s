# Bitwise functions for 64-bit operations
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "macros.s"

.section .text

.global bitlen64
.global lshift64
.global getbit64
.global setbit64

# returns number of bits in 64-bit number
# Arguments:
#     a0 - least significant word
#     a1 - most significant word
fn bitlen64
    stack_alloc
    pushb zero, 8                      # set adder to 0
    beqz a1, 1f                        # jump if most significant word is zero
        mv a0, a1                      # make a0 most significant word
        li t0, 32                      # set adder to 32
        pushb t0, 8                    # and save it on the stack
1:  call bitlen32
    popb t0, 8
    add a0, a0, t0                     # increase the result by the adder
    stack_free
    ret
endfn


# 64-bit left shift by 1
# Arguments
#     a0 - least significant word
#     a1 - most significant word
# Returns: same as above
fn lshift64
    # .set BIT19, 1 << 19
    # lui t0, BIT19                      # set bit 31 to 1
    li t0, 1
    slli t0, t0, 31
    and t0, a0, t0                     # AND it with the least significant word
    snez t0, t0                        # produce carry flag
    slli a0, a0, 1                     # shift both words left
    slli a1, a1, 1
    or a1, a1, t0                      # and OR the most significant word with the carry flag
    ret
endfn


# Arguments:
#     a0 - lo-word
#     a1 - hi-word
#     a2 - bit no
fn getbit64
    stack_alloc
    slti t0, a2, 32
    bnez t0, 1f
        mv a0, a1
        addi a1, a2, -32
        j 2f
1:
    mv a1, a2
2:
    call getbit
    stack_free
    ret
endfn


# Arguments:
#     a0 - lo-word
#     a1 - hi-word
#     a2 - bit no
#     a3 - value
fn setbit64
    stack_alloc
    push a0, 8
    push a1, 4

    slti t0, a2, 32
    beqz t0, 1f
        mv a1, a2
        mv a2, a3
        call setbit
        pop a1, 4
        j 2f
1:
    mv a0, a1
    addi a1, a2, -32
    mv a2, a3
    call setbit
    mv a1, a0
    pop a0, 8
2:
    stack_free
    ret
endfn
