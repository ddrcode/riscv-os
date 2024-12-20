# Converts a number (integer) into a string
# Inspired by this implementation in C:
# https://www.geeksforgeeks.org/implement-itoa/
# Params:
#     a0 - number to be converted
#     a1 - pointer to string
#     a2 - base
# Returns:
#     a0 - string length
itoa:
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
    setz t2                            # sign indicator (1 for negative, 0 otherwise)
    bgez a0, 2f                        # skip if number >= 0
        xori a0, a0, -1                # make number positive (a = (a^-1)+1)
        inc a0
        li t2, 1                       # mark sign indicator as negative
2:
    beqz a0, 4f                        # jump if number is zero
        rem t1, a0, a2                 # t1 = number % base
        blt t1, a4, 3f                 # jump to 2: if t1 < 10
            addi t1, t1, 7             # magic :-)  ('A'-t1+'0' = 7)
3:
        addi t1, t1, '0'               # t1 += '0'
        sb t1, (t0)                    # store bcharacter
        inc t0                         # increment string pointer
        div a0, a0, a2                 # number /= base
        j 2b
4:
    beqz t2, 5f                        # skip if sign indicator is 0
        li t1, '-'                     # add the - sign for negative number
        sb t1, (t0)
        inc t0                         # and increase the pointer
5:
    li t1, 0                           # finish string with '\0'
    sb t1, (t0)
    sub t0, t0, a1                     # compute string length

    push ra
    push t0                            # preserve string length on stack
    mv a0, a1                          # pointer to the string
    mv a1, t0                          # string length
    call mem_reverse                   # reverse the string
    pop a0                             # return string length
    pop ra
6:
    ret


# Computes length of a string
# Arguments:
#     a0 - string pointer
# Returns:
#     a0 - length
strlen:
    setz t0
1:
    lb t1, (a0)
    beqz t1, 2f
        inc a0
        inc t0
        j 1b
2:
    mv a0, t0
    ret


# Compare two strings
# Arguments
#     a0 - pointer to string 1
#     a1 - pointer to string 2
strcmp:
    setz t2                                        # default result (strings not equal)
1:                                                 # do
        lb t0, (a0)
        lb t1, (a1)
        bne t0, t1, 3f                             # break when characters don't match
        beqz t0, 2f                                # break when end of the string
        inc a0
        inc a1
        j 1b
2:                                                 # strings equal
    li t2, 1
3:
    mv a0, t2                                      # set the result
    ret

