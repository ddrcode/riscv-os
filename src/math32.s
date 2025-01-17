# Math functions for 32-bit operations
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "macros.s"
.include "consts.s"

.section .text

.global udiv32
.global urem32
.global pow32
.global smul32

# Unsigned, 32-bit division
# Implements the following algorithm:
#   if D = 0 then error(DivisionByZeroException) end
#   Q := 0                  -- Initialize quotient and remainder to zero
#   R := 0
#   for i := n − 1 .. 0 do  -- Where n is number of bits in N
#     R := R << 1           -- Left-shift R by 1 bit
#     R(0) := N(i)          -- Set the least-significant bit of R equal to bit i of the numerator
#     if R ≥ D then
#       R := R − D
#       Q(i) := 1
#     end
#   end
#
# Implementation
# N - a0
# D - a1
# Q - a2
# R - a3
# i - t0
.type udiv32, @function
udiv32:
    stack_alloc
    push a0, 8
    push a1, 4

    call bitlen32
    mv t0, a0
    pop a0, 8
    pop a1, 4
    setz a2
    setz a3

    li t2, 1                           # t2 = 2
    sll t2, t2, t0                     # t2 = t2 << i

1:
    dec t0
    bltz t0, 2f
        srli t2, t2, 1                 # t2 >>= 1
        and t1, a0, t2                 # t1 = t2 & N
        snez t1, t1                    # t1 = t1 != 0 ? 1 : 0
        slli a3, a3, 1                 # R = R << 1
        or a3, a3, t1                  # R(0) = N(i)
        blt a3, a1, 1b                 # branch if R < D
            sub a3, a3, a1             # R = R - D
            or a2, a2, t2              # Q(i) = 1
    j 1b

2:
    mv a0, a2
    mv a1, a3

    stack_free
    ret


fn urem32
    stack_alloc
    call udiv32
    mv a0, a1
    stack_free
    ret
endfn

# Computes 32-bit integer power of x^y
# Arguments:
#     a0 - x
#     a1 - y
# Returns:
#     a0 - result (or x if error)
#     a5 - error code (or 0)
.type pow32, @function
pow32:
    setz a5                            # set error code
    bltz a1, 2f
    beqz a1, 3f

    mv t0, a0
1:                                     # Compute power
    dec a1
    beqz a1, 4f
    mul t0, t0, a0
    j 1b

2:  li a5, ERR_NOT_SUPPORTED           # Handle negative
    j 5f

3:  li t0, 1                           # Handle x^0

4:  mv a0, t0
5:  ret


# Signed, 32-bit integer multiplication returning 64-bit product
# Arguments:
#     a0 - x
#     a1 - y
# Returns:
#     a0 - x*y lower 32 bits
#     a1 - x*y upper 32 bits
.type smul32, @function
smul32:
    mulh    t0, a1, a0
    mul     a0, a1, a0
    mv      a1, t0
    ret


