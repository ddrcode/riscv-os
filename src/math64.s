# Math functions for 64-bit operations
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.section .text

.global add64
.global usub64
.global bitlen32
.global bitlen64

# 64-bit unsigned divison (x/y)
# Arguments
#     a0 - least significant word of x
#     a1 - most significant word of x
#     a2 - least significant word of y
#     a3 - most significant word of y
# Returns
#     a0 - least significant word of the result
#     a1 - most significant word of the result
#     a2 - least significant word of the remainder
#     a3 - most significant word of the remainder
udiv64:
    .set nlo, 40
    .set nhi, 36
    .set dlo, 32
    .set dhi, 28
    .set idx, 24
    .set qlo, 20
    .set qhi, 16
    .set rlo, 12
    .set rhi, 8
    .set idx, 4
    .set nth, 0

    stack_alloc 48

    bnez a1, 1f                        # test whether 32-bit div can be executed
    bnez a3, 1f                        # which is when both most significant words are 0

    # 32-bit division
    mv a1, a2
    call udiv32
    mv a2, a1
    setz a1
    setz a3
    j 4f

1:                                     # handle 62-bit division
    push a0, nlo
    push a1, nhi
    push a2, dlo
    push a3, dhi

    push zero, qlo
    push zero, qhi
    push zero, rlo
    push zero, rhi

    mv a3, zero
    mv a2, zero

    call bitlen64
    mv t0, a0                          # figure out iterations index

    addi t1, t0, -31                   # compute t2
    bgez t1, 11f
        mv t1, t0                      # when i < 32
        j 12f
11: mv a0, a1                          # a0 = nhi
12: li t2, 1                           # t2 = 2
    sll t2, t2, t1                     # t2 = t2 << (i > 31 ? i-32 : i)

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
    dec t0                             # idx--
    bltz t0, 4f                        # finish if idx < 0
        li t1, 31
        bne t0, t1, 22f               # if idx == 31
            li t2, 1
            slli t2, t2, 31            # set t2 to 1<<31
            pop a0, nlo
            push a3, rhi
            pop a3, rlo
            j 23f
22:     srli t2, t2, 1                 # ...otherwise t2 >>= 1
23:     and t1, a0, t2                 # t1 = t2 & N
        snez t1, t1                    # t1 = t1 != 0 ? 1 : 0
        slli a3, a3, 1                 # R = R << 1
        or a3, a3, t1                  # R(0) = N(i)
        blt a3, a1, 2b                 # branch if R < D
            sub a3, a3, a1             # R = R - D
            or a2, a2, t2              # Q(i) = 1
    j 2b


4:  stack_free 48
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

# 64-bit unsigned subtraction
# It uses 64-bit add based on principle that
# x-y = x + ~y + 1
# Arguments
#     a0 - least significant word of x
#     a1 - most significant word of x
#     a2 - least significant word of y
#     a3 - most significant word of y
# Returns
#     a0 - least significant word of the result
#     a1 - most significant word of the result
usub64:
    stack_alloc
    not a2, a2
    not a3, a3
    call add64
    li a2, 1
    li a3, 0
    call add64
    stack_free
    ret


# returns number of bits in 64-bit number
# Arguments:
#     a0 - least significant word
#     a1 - most significant word
bitlen64:
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


# 64-bit left shift
# Arguments
#     a0 - least significant word
#     a1 - most significant word
# Returns: same as above
lshift64:
    .set BIT19, 1 << 19
    lui t0, BIT19                      # set bit 31 to 1
    and t0, a0, t0                     # AND it with the least significant word
    snez t0, t0                        # produce carry flag
    slli a0, a0, 1                     # shift both words left
    slli a1, a1, 1
    or a1, a1, t0                      # and OR the most significant word with the carry flag
    ret
