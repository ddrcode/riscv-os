# String funtions of RISC-V OS
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "macros.s"
.include "consts.s"

.global itoa
.global atoi
.global utoa
.global strlen
.global strcmp
.global strcpy
.global str_find_char
.global str_align_right

.section .text


# Private function supporting itoa and utoa. It converts an unsigned
# number into a reversed string and returns string length in a0.
# Functions that use this tool must at least reverse the strig
# and add a sign character (itoa).
# Arguments:
#     a0 - number to be converted
#     a1 - pointer to string
#     a2 - base
# Returns:
#     a0 - string length
fn _num_to_reversed_str
    mv t0, a1
    bnez a0, 1f                        # jump if number is not zero
        li t1, '0'                     # generate "0\0" string and jump to the end
        sb t1, (t0)                    # store '0'
        li t1, 0
        sb t1, 1(t0)                   # store '\0'
        li a0, 1                       # hardcode result to 1
        j 6f                           # exit
1:
    li a4, 10                          # constant to compare base 10
2:
    beqz a0, 4f                        # jump if number is zero
        remu t1, a0, a2                 # t1 = number % base
        blt t1, a4, 3f                 # jump to 3: if t1 < 10
            addi t1, t1, 'a'-10-'0'    # use character as a digit > 9
3:
        addi t1, t1, '0'               # t1 += '0'
        sb t1, (t0)                    # store bcharacter
        inc t0                         # increment string pointer
        divu a0, a0, a2                # number /= base
        j 2b
4:
5:
    li t1, 0                           # finish string with '\0'
    sb t1, (t0)
    sub a0, t0, a1                     # compute string length
6:
    ret
endfn


# Converts a signed number  into a string
# Inspired by this implementation in C:
# https://www.geeksforgeeks.org/implement-itoa/
# Params:
#     a0 - number to be converted
#     a1 - pointer to string
#     a2 - base
# Returns:
#     a0 - string pointer
fn itoa
    stack_alloc
    push a1, 8
    pushb zero, 4

    li t1, 10                          # base-10 for comparisons
    bgez a0, 1f                        # skip if number >= 0
    bne a2, t1, 1f                     # or if base != 10
        xori a0, a0, -1                # make number positive (a = (a^-1)+1)
        inc a0
        li t2, 1                       # mark sign indicator as negative
        pushb t2, 4                    # and save it on the stack
1:
    call _num_to_reversed_str          # call generic conversion (it returns string length in a0)

    pop a1, 8                          # retrieve string pointer
    popb t2, 4                         # retrieve sign indicator
    beqz t2, 2f                        # and finish if non-negative
        add t0, a1, a0                 # compute end-of-string address
        li t1, '-'                     # add the - sign for negative number
        sb t1, (t0)
        sb zero, 1(t0)                 # close the string
        inc a0                         # and increase its length
2:
    mv t0, a0
    mv a0, a1                          # pointer to the string
    mv a1, t0                          # string length
    blt a1, t0, 3f                     # don't reverse the string if is 1-char long
        call mem_reverse               # reverse the string otherwise
3:
    pop a0, 8                          # return string pointer
    stack_free
    ret
endfn


# Converts an unsigned number into a string
# Inspired by this implementation in C:
# https://www.geeksforgeeks.org/implement-itoa/
# Params:
#     a0 - number to be converted
#     a1 - pointer to string
#     a2 - base
# Returns:
#     a0 - string pointer
fn utoa
    stack_alloc
    push a1, 8                         # preserve the string pointer on the stack
    call _num_to_reversed_str          # convert number to RTL string

    li t0, 2
    mv a1, a0                          # string length
    pop a0, 8                          # retrieve string pointer

    blt a1, t0, 1f                     # don't reverse the string if is 1-char long
        call mem_reverse               # reverse the string otherwise
1:
    stack_free
    ret
endfn


# Converts string to a number (if possible)
# Arguments:
#     a0: pinter to a string
#     a1: base
# Returns:
#     a0: Result (number)
#     a5: Error code
# TODO Handle negative numbers
# TODO Hanlde base (a1) > 10
fn atoi
    stack_alloc
    pushb   a1, 8
    push    a0, 4


    li      t0, 2
    blt     a1, t0, 2f                 # check if base < 2
    li      t0, 36
    bgt     a1, t0, 2f                 # check if base > 36

    call    strlen                     # get string length
    mv      t0, a0                     # loop/string counter
    dec     t0
    pop     a0, 4                      # string pointer
    popb    a1, 8                      # base
    li      t2, 1                      # multiplier (1, 10, 100, etc)
    setz    a3                         # result
    li      a5, '0'                    # constant

1:
    add     t1, a0, t0                 # compute digit address
    lbu     a4, (t1)                   # load byte (character)
    sub     a4, a4, a5                 # a4 -= '0'
    mul     a4, a4, t2                 # a4 *= t2 (position multiplier)
    add     a3, a3, a4                 # a3 += a4
    dec     t0                         # decrease pointer
    bltz    t0, 3f                     # stop if pointer < 0
    mul     t2, t2, a1                 # compute position multiplier (1, 10, 100, ...)
    j       1b
2:                                     # handle invalid base
    li      a5, ERR_INVALID_ARGUMENT
    setz    a0
    j       4f
3:                                     # Handle correct result
    setz    a5                         # Error code
    mv      a0, a3                     # Set result value
4:
    stack_free
    ret
endfn


# Computes length of a string
# Arguments:
#     a0 - string pointer
# Returns:
#     a0 - length
fn strlen
    setz t0
1:
    lbu t1, (a0)
    beqz t1, 2f
        inc a0
        inc t0
        j 1b
2:
    mv a0, t0
    ret
endfn


# Compare two strings
# Arguments
#     a0 - pointer to string 1
#     a1 - pointer to string 2
fn strcmp
    setz t2                            # default result (strings not equal)
1:                                     # do
        lbu t0, (a0)
        lbu t1, (a1)
        bne t0, t1, 3f                 # break when characters don't match
        beqz t0, 2f                    # break when end of the string
        inc a0
        inc a1
        j 1b
2:                                     # strings equal
    li t2, 1
3:
    mv a0, t2                          # set the result
    ret
endfn


# Find position of a char inside a string
# Arguments
#     a0 - pointer to a string
#     a1 - char to find
# Returns
#     a0 - position of a char (or -1 if not found)
fn str_find_char
    li t0, -1                          # set default result
    mv t1, a0
1:
    lbu t2, (t1)
    beqz t2, 3f
    beq a1, t2, 2f
    inc t1
    j 1b
2:
    sub t0, t1, a0
3:
    mv a0, t0
    ret
endfn


fn strcpy
    stack_alloc
    push a0, 8
    push a1, 4
    mv a0, a1
    call strlen
    mv a2, a0
    pop a0, 8
    pop a1, 4
    call memcpy
    pop a0, 8
    stack_free
    ret
endfn


# If a string is shorter than it's memory region
# moves all characters to the right and fils
# the gap with given char
# Arguments
#      a0 - pointer to the string
#      a1 - total length of the string
#      a2 - fill character
fn str_align_right
    stack_alloc
    push s0, 8
    push s1, 4
    push a2, 0

    mv s0, a0
    mv s1, a1

    call strlen
    bge a0, s1, 3f
    beqz a0, 3f

    add t0, s0, a0

    add t1, s0, s1
    dec t1
    sb zero, (t1)
    pop a2, 0
1:
    dec t0
    blt t0, s0, 2f
    dec t1

    lbu t2, (t0)
    sb t2, (t1)
    j 1b

2:
    dec t1
    blt t1, s0, 3f
    sb a2, (t1)
    j 2b

3:
    mv a0, s0
    pop s0, 8
    pop s1, 4
    stack_free
    ret
endfn

