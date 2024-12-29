# Math functions
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.section .text

.global pow
.global udiv32
.global bitlen32
.global bitlen64

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
udiv32:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw a0, 8(sp)
    sw a1, 4(sp)

    call bitlen32
    mv t0, a0
    lw a0, 8(sp)
    lw a1, 4(sp)
    setz a2
    setz a3

        li t2, 1                       # t1 = 1
        sll t2, t2, t0                 # t1 = t1 << i

1:
    dec t0
    bltz t0, 2f
        srli t2, t2, 1
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

    lw ra, 12(sp)
    addi sp, sp, 16
    ret

# 64-bit unsigned divison (x/y)
# Arguments
#     a0 - least significant byte of x
#     a1 - most significant byte of x
#     a2 - least significant byte of y
#     a3 - most significant byte of y
# Returns
#     a0 - least significant byte of the result
#     a1 - most significant byte of the result
#     a2 - least significant byte of the remainder
#     a3 - most significant byte of the remainder
udiv64:
    push ra, 32

    bnez a1, 1f                        # test whether 32-bit div can be executed
    bnez a3, 1f                        # which is when both most significant bytes are 0

    # 32-bit division
    mv a1, a2
    call udiv32
    mv a2, a1
    setz a1
    setz a3
    j 4f

1:                                     # handle 62-bit division
    sw a0, 24(sp)
    sw a1, 20(sp)
    sw a2, 16(sp)
    sw a3, 12(sp)

    call bitlen64
    mv t0, a0

# Implementation 32
# N - a0
# D - a1
# Q - a2
# R - a3
# i - t0


# Implementation 64
# Qlo - a0
# Qhi - a1
# Rlo - a2
# Rhi - a3
# i - t0
2:
    dec t0
    beqz t0, 2f
        li t2, 1                       # t1 = 1
        sll t2, t2, t0                 # t1 = t1 << i
        and t1, a0, t2                 # t1 = t1 & N
        snez t1, t1                    # t1 = t1 != 0 ? 1 : 0
        slli a3, a3, 1                 # R = R << 1
        or a3, a3, t1                  # R(0) = N(i)
        blt a3, a1, 1b                 # if R < D
            sub a3, a3, a1             # R = R - D
            or a2, a2, t2              # Q(i) = 1
    j 2b


4:  pop ra, 32
    ret

# 64-bit unsigned subtraction
# Arguments
#     a0 - least significant byte of x
#     a1 - most significant byte of x
#     a2 - least significant byte of y
#     a3 - most significant byte of y
# Returns
#     a0 - least significant byte of the result
#     a1 - most significant byte of the result
usub64:
    ret

# returns number of bits in 32-bit number
bitlen32:
    li t0, 0b11111111111111111111111111111111
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

# returns number of bits in 64-bit number
# Arguments:
#     a0 - least significant byte
#     a1 - most significant byte
bitlen64:
    push ra, 16
    sb zero, 8(sp)                     # set adder to 0
    beqz a1, 1f                        # jump if most significant byte is zero
        mv a0, a1                      # make a0 most significant byte
        li t0, 32                      # set adder to 32
        sb t0, 8(sp)                   # and save it on the stack
1:  call bitlen32
    lb t0, 8(sp)
    add a0, a0, t0                     # increase the result by the adder
    pop ra, 16
    ret

# Computes 32-bit integer power of x^y
# Arguments:
#     a0 - x
#     a1 - y
# Returns:
#     a0 - result (or x if error)
#     a5 - error code (or 0)
pow:
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
smul32:
    mulh    t0, a1, a0
    mul     a0, a1, a0
    mv      a1, t0
    ret


# Adds two 64-bit numbers (x+y)
# Arguments:
#     a0 - least significant word of x
#     a1 - most significant word of x
#     a2 - least significant word of y
#     a3 - most significant word of y
# Returns:
#     a0 - least significant word of the result
#     a1 - most significant word of the result
#     a2 - carry bit if overflow
add64:
    add t0, a0, a2                     # add the least significant words
    sltu t2, t0, a2                    # carry bit from previous addition
                                       # t2 = 1 if (a0+a2) < a2
    add t1, a1, a3                     # add the most significant words
    add t1, t1, t2                     # add the carry out
    sltu a2, t1, a3                    # carry bit from previous addition
    mv a0, t0
    mv a1, t1
    ret

