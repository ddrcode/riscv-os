# Converts a number (integer) into a string
# Inspired by this implementation in C:
# https://www.geeksforgeeks.org/implement-itoa/
# Params:
#     a0 - number to be converted
#     a1 - pointer to string
#     a2 - base
# Returns:
#     a0 - string length
# TODO handle negative numbers
itoa:
    mv t0, a1
    bnez a0, 1f                        # jump if number is not zero
        li t1, '0'                     # generate "0\0" string and jump to the end
        sb t1, (t0)                    # store '0'
        li t1, 0
        sb t1, 1(t0)                   # store '\0'
        li a0, 1                       # hardcode result to 1
        j 5f                           # exit

    bgez a0, 1f                        # jump to 1: for number >= 0
        xori a0, a0, -1                # make number positive (a = (a^-1)+1)
        inc a0

1:
    li a4, 10                          # constant for comparisons
    beqz a0, 3f                        # jump if number is zero
        rem t1, a0, a2                 # t1 = number % base
        blt t1, a4, 2f                 # jump to 2: if t1 < 10
            addi t1, t1, 7             # magic :-)  ('A'-t1+'0' = 7)
2:
        addi t1, t1, '0'               # t1 += '0'
        sb t1, (t0)                    # store bcharacter
        inc t0                         # increment string pointer
        div a0, a0, a2                 # number /= base
        j 1b
3:
    li t1, 0                           # finish string with '\0'
    sb t1, (t0)
4:
    sub t0, t0, a1                     # compute string length

    push ra
    push t0                            # preserve string length on stack
    mv a0, a1                          # pointer to the string
    mv a1, t0                          # string length
    call mem_reverse                   # reverse the string
    pop a0                             # return string length
    pop ra
5:
    ret


