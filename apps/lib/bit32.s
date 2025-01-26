# Bitwise functions for 32-bit operations
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "macros.s"

.section .text

.global bitlen32
.global getbit
.global setbit

# returns number of bits in 32-bit number
.type bitlen32, @function
bitlen32:
    not t0, zero
    setz t1
1:
    and t2, a0, t0
    beqz t2, 2f
    inc t1
    slli t0, t0, 1
    beqz t0, 2f
    j 1b
2:
    mv a0, t1
    ret

# Get n-th bit from word
# Arguments:
#     a0 - word
#     a1 - bit
# Returns: 0 or 1
.type getbit, @function
getbit:
    li t0, 1
    sll t0, t0, a1
    and t0, a0, t0
    snez a0, t0
    ret

# Set n-th bit from word
# Arguments:
#     a0 - word
#     a1 - bit
#     a2 - value
.type setbit, @function
setbit:
    li t0, 1
    sll t0, t0, a1
    bnez a2, 1f
        not t0, t0
        and a0, a0, t0                 # clear bit
        j 2f
1:  or a0, a0, t0                      # set bit
2:  ret


