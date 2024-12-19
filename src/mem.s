# Copies n-bytes from address to address.
# It copies data by words (4 bytes at once) decreasing
# for every iteration a2 by 4. If a2 < 4 then copies the
# rest byte by byte
# Arguments
#     a0 - dst address
#     a1 - src address
#     a2 - number of bytes to be copied
# Returns
#     a0 - dst address where copying has finished
#     a1 - src address where copying has finished
# TODO add check for address boundaries
memcpy:
1:                                  # copy words
    addi t0, a2, -4                 # compute next index
    bltz t0, 2f                     # if less than zero jump to 2
    lw t1, (a1)
    sw t1, (a0)
    mv a2, t0                       # decrease index by 4
    addi a0, a0, 4                  # increase dst address by 4
    addi a1, a1, 4                  # increase src address by 4
    j 1b
2:                                  # copy bytes (for len < 4)
    beqz a2, 3f                     # if zero - finish
    lb t1, (a1)
    sb t1, (a0)
    inc a0
    inc a1
    dec a2
    j 2b
3:                                  # finish
    ret


# Fills memory with a given value
# Arguments:
#     a0 - starting adress
#     a1 - number of bytes to fill
#     a2 - value (byte)
# TODO respect memory boundaries
# TODO optimize it with 32-bit operations
memfill:
1:
    beqz a1, 2f
    sb a2, (a0)
    dec a1
    inc a0
    j 1b
2:
    ret


# reverses bytes in memory range
# params
#    a0 pointer
#    a1 number of bytes to reverse
mem_reverse:
    mv t0, a0
    add t1, a0, a1                      # Compute the end addr...
    dec t1                              # end=start+len-1
1:
    bge t0, t1, 2f                      # Break if start>=end
    lb t2, (t0)                         # Swap bytes...
    lb a4, (t1)
    sb a4, (t0)
    sb t2, (t1)
    dec t1                              # decrement end pointer
    inc t0                              # increment start pointer
    j 1b
2:
    ret
