
clear_screen:
    la a0, screen                   # set a0 to beginning of screen region
    li t0, 0x20202020               # set t0 to 4 x space sign
    li t1, 250                      # t1 is a counter (250 iteration x 4 bytes)
1:
    sw t0, 0(a0)                    # save t0 address under a0
    dec t1                          # decrement t1
    beqz t1, 2f                     # if t1 is zero jump to 2:
    addi a0, a0, 4                  # increase a0 by 4 (shift screen address by 4 bytes)
    j 1b                            # jump to 1
2:
    ret


# Copies string to screen memory
# a0 - a string address
print_str:
    push ra
    push a0
    call get_cursor_offset          # get cursorsor offset to a0
    la a1, screen                   # load screen address..
    mv t1, a1                       # copy screen address to t1
    add a1, a1, a0                  # ...and increase it by the offset
    pop a0
1:
    lb t0, (a0)                     # Load a single byte of a string
    beqz t0, 2f                     # Exit loop if \0
    sb t0, (a1)                     # Write character to screen memory
    inc a0                          # Increment string pointer
    inc a1                          # Increment screen memory pointer
    j 1b
2:
    sub a0, a1, t1                  # Compute offset for new cursor position
    call set_cursor_pos_from_offset
    pop ra
    ret


# Sets cursor position
# a0 - cursor x position
# a1 - cursor y position (remains unchanged)
# returns cursor 16-bit number representing cursor in a0
set_cursor_pos:
    slli t0, a1, 8
    or a0, a0, t0
    la t0, cursor
    sh a0, (t0)
    ret

# a0 - offset
set_cursor_pos_from_offset:
    setz a1
    li t0, 40
1:
    sub a0, a0, t0
    bltz a0, 2f
    inc a1
    j 1b
2:
    add a0, a0, t0

    slli t0, a1, 8
    or t0, t0, a0
    la t1, cursor
    sh t0, (t1)

    ret


# Returns cursor position
# Arguments: none
# Returns:
#    a0 - x position
#    a1 - y position
get_cursor_pos:
    la t0, cursor
    lh a0, (t0)
    srai a1, a0, 8
    andi a0, a0, 0xff
    ret


# Computes cursor offset - how many bytes it's away from the
# begining of the screen memory.
# Formula: 40*y+x
# Arguments: none
# Returns:
#     a0: offset
get_cursor_offset:
    push ra
    call get_cursor_pos             # get cursor position as x,y coords
    pop ra

    slli t0, a1, 5                  # multiply y by 32
    slli t1, a1, 3                  # multiply y by 8
    add t0, t0, t1                  # sum the above to get y*40
    add a0, a0, t0                  # x+y
    ret
