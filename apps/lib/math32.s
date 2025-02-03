# Math functions for 32-bit operations
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "macros.s"
.include "consts.s"

.section .text

.global abs
.global udiv32
.global urem32
.global div32
.global rem32
.global pow32
.global mul32


# Returns an absolute value of a0
fn abs
    bgez a0, 1f
    not a0, a0
    inc a0
1:  ret
endfn


# Returns a sign of a0
# 1 - positive, 0 - zero, -1 - negative
fn sign
    mv t0, zero
    beqz a0, 1f
    li t0, 1
    bgtz a0, 1f
    li t0, -1
1:
    mv a0, t0
    ret
endfn

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
fn udiv32
.if HAS_EXTENSION_M == 0
    stack_alloc
    push a0, 8
    push a1, 4

    call bitlen32                      # returns how many bits the number occupies
    mv t0, a0
    pop a0, 8
    pop a1, 4
    setz a2
    setz a3

    addi t1, t0, -1
    li t2, 1                           # t2 = 1
    sll t2, t2, t1                     # t2 = t2 << (i-1)

1:
    dec t0
    bltz t0, 3f
        and t1, a0, t2                 # t1 = t2 & N
        snez t1, t1                    # t1 = t1 != 0 ? 1 : 0
        slli a3, a3, 1                 # R = R << 1
        or a3, a3, t1                  # R(0) = N(i)
        bltu a3, a1, 2f                 # branch if R < D
            sub a3, a3, a1             # R = R - D
            or a2, a2, t2              # Q(i) = 1
2:
        srli t2, t2, 1                 # t2 >>= 1
    j 1b

3:
    mv a0, a2
    mv a1, a3

    stack_free
    ret
.else
    divu t0, a0, a1
    remu a1, a0, a1
    mv a0, t0
.endif
    ret
endfn


# Computes remainder of unsigned division a0 by a1
fn urem32
.if HAS_EXTENSION_M == 0
    stack_alloc
    call udiv32
    mv a0, a1
    stack_free
.else
    remu a0, a0, a1
.endif
    ret
endfn


# Computes signed division of a0 by a1
# Algorithm: it performs udiv32(abs(x), abs(y)) and then
# it adjusts sign accordingly.
# TODO the function is way too long and contains too many function calls - optimize!
# Argumenst
#     a0 - x
#     a1 - y
# Results
#     a0 - x/y
#     a1 - x%y
fn div32
.if HAS_EXTENSION_M == 0
    .set x, 16
    .set y, 12
    .set q, 24
    .set r, 20
    .set xabs, 8
    .set xsign, 4

    stack_alloc 32
    push s0, q
    push s1, r
    push a0, x
    push a1, y

    call abs
    push a0, xabs

    pop a0, y
    call abs

    mv a1, a0
    pop a0, xabs
    call udiv32
    mv s0, a0
    mv s1, a1

    pop a0, x
    call sign
    push a0, xsign

    pop a0, y
    call sign
    mv a1, a0
    pop a0, xsign

    beq a0, a1, 1f
        neg s0, s0
        bltz a0, 2f
        j 3f

1: # xsign == ysign
    bgtz a0, 3f

2: # rem = -rem
    neg s1, s1

3: # end
    mv a0, s0
    mv a1, s1

    pop s0, 24
    pop s1, 20
    stack_free 32
.else
    div t0, a0, a1
    rem a1, a0, a1
    mv a0, t0
.endif
    ret
endfn


# Computes signed reminder of a0/a1
fn rem32
.if HAS_EXTENSION_M == 0
    stack_alloc
    call div32
    mv a0, a1
    stack_free
.else
    rem a0, a0, a1
.endif
    ret
endfn

# Computes 32-bit integer power of x^y
# Arguments:
#     a0 - x
#     a1 - y
# Returns:
#     a0 - result (or x if error)
#     a5 - error code (or 0)
fn pow32
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
endfn


# Signed, 32-bit integer multiplication returning 64-bit product
# Arguments:
#     a0 - x
#     a1 - y
# Returns:
#     a0 - x*y lower 32 bits
#     a1 - x*y upper 32 bits
fn mul32
    mulh    t0, a1, a0
    mul     a0, a1, a0
    mv      a1, t0
    ret
endfn

