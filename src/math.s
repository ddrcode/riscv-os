# Math functions
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.section .text

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
#
smul32:
    mulh    t0, a1, a0
    mul     a0, a1, a0
    mv      a1, t0
    ret


