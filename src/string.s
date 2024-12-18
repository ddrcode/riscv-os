# Converts a number (integer) into a string
# Inspiration: https://www.geeksforgeeks.org/implement-itoa/
# Params:
#     a0 - number to be converted
#     a1 - pointer to string
#     a2 - base
# Returns:
#     a0 - string length
# TODO handle negative numbers
# TODO handle base > 10
itoa:
    mv t0, a1
    bnez a0, 1f

    # handling 0
    li t1, '0'
    sb t1, (t0)
    li t1, '\0'
    sb t1, 1(t0)
    inc t0
    j 3f
1:
    beqz a0, 2f
        rem t1, a0, a2
        addi t1, t1, '0'
        sb t1, (t0)
        inc t0
        div a0, a0, a2
    j 1b
2:
    li t1, '\0'
    sb t1, (t0)
3:
    sub a0, t0, a1
    ret
