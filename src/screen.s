.section .text

.global clear_screen
.global print_str
.global println
.global show_cursor

clear_screen:
    push ra
    la a0, screen
    li a1, SCREEN_WIDTH*SCREEN_HEIGHT
    li a2, 0x20
    call memfill

    setz a0
    setz a1
    call set_cursor_pos

    pop ra
    ret


# Copies string to screen memory at the cursor position
# Arguments:
#     a0 - a pointer to the beginning of the string
# Returns:
#     a0 - x position of the cursor
#     a1 - y position of the cursor
print_str:
    addi sp, sp, -16                # prepare the stack
    sw ra, 12(sp)
    sw a0, 8(sp)
    sw a1, 4(sp)
    call strlen                     # get string length
    sw a0, 0(sp)                    # and push it to the stack

    call get_cursor_offset          # get cursor offset
    la a1, screen                   # load screen address..
    mv t1, a1                       # copy screen address to t1
    add a1, a1, a0                  # ...and increase it by the offset

    lw t2, 0(sp)                    # retrieve string length
    add t2, t2, a1                  # and compute the end address

    li t0, SCREEN_WIDTH*SCREEN_HEIGHT
    add t0, t0, t1                  # compute the end address of the screen

    ble t2, t0, 1f                  # skip if string fits on the screen, scroll otherwise
        sub t0, t2, t0              # compute how many lines to scroll...
        li a0, SCREEN_WIDTH
        mv t0, a0
        div a0, t0, a0
        mul t0, t0, a0              # and adjust the start address (a1) accordingly
        sub a1, a1, t0
        sw a1, 0(sp)                # preserver the start address on the stack
        call scroll                 # and scroll
        la t1, screen
        lw a1, 0(sp)

1:
    lw a0, 8(sp)                    # retrieve pointer to string
2:
    lb t0, (a0)                     # Load a single byte of a string
    beqz t0, 3f                     # Exit loop if \0
        sb t0, (a1)                     # Write character to screen memory
        inc a0                          # Increment string pointer
        inc a1                          # Increment screen memory pointer
        j 2b
3:
    sub a0, a1, t1                  # Compute offset for new cursor position
    call set_cursor_pos_from_offset

    lw ra, 12(sp)
    addi sp, sp, 16
    ret


# Copies string to screen memory and sets cursor to a new line
# Arguments:
#     a0 - pointer to the beginning of the string
# Returns:
#     a0 - x position of the cursor
#     a1 - y position of the cursor
println:
    push ra
    call print_str                  # Print text at cursor position
    setz a0                         # Set cursor_x to 0
    inc a1                          # increment cursor_y

    li t0, SCREEN_HEIGHT
    blt a1, t0, 1f                  # if cursor_y < SCREEN_HEIGHT jump to end
        dec a1
        push a0
        push a1
        call scroll                 # scroll screen content up
        pop a1
        pop a0

1:
    call set_cursor_pos             # set cursor position to a new value
    call get_cursor_pos             # and get it (for return)
    pop ra
    ret


# Sets cursor position
# a0 - cursor x position
# a1 - cursor y position (remains unchanged)
# returns cursor 16-bit number representing cursor in a0
# TODO check screen boundaries
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


show_cursor:
    push ra
    call get_cursor_offset
    la t0, screen
    add t0, t0, a0
    li t1, '_'
    sb t1, (t0)
    pop ra
    ret


# Scrolls screen up by one line
# Arguments: a0 - number of lines to scroll (ignored)
# TODO make it respect a0 argument
scroll:
    # copy screen memory one line up
    push ra
    la a0, screen
    addi a1, a0, SCREEN_WIDTH
    li a2, SCREEN_WIDTH*(SCREEN_HEIGHT-1)
    call memcpy

    # fill the last line with spaces
    li a1, SCREEN_WIDTH
    li a2, 32
    call memfill

    # adjust cursor position (one line up)
    la t0, cursor
    lb t1, 1(t0)
    beqz t1, 1f
    dec t1
    sb t1, 1(t0)

1:
    pop ra
    ret


.section .data

cursor: .half 0
screen: .fill SCREEN_WIDTH*SCREEN_HEIGHT, 1, 32

