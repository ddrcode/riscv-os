# (Text) Screen handling functions
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "macros.s"
.include "config.s"

.global clear_screen
.global scr_print
.global scr_println
.global show_cursor
.global set_cursor_pos
.global print_screen
.global scr_backspace

.section .text

clear_screen:
    stack_alloc 4
    la a0, screen
    li a1, SCREEN_WIDTH*SCREEN_HEIGHT
    li a2, 0x20
    call memfill

    setz a0
    setz a1
    call set_cursor_pos

    setz a5                            # set exit code
    stack_free 4
    ret


# Copies string to screen memory at the cursor position
# Arguments:
#     a0 - a pointer to the beginning of the string
# Returns:
#     a0 - x position of the cursor
#     a1 - y position of the cursor
scr_print:
    stack_alloc                     # prepare the stack
    push a0, 8
    push a1, 4
    call strlen                     # get string length
    push a0, 0                      # and push it to the stack

    call get_cursor_offset          # get cursor offset
    la a1, screen                   # load screen address..
    mv t1, a1                       # copy screen address to t1
    add a1, a1, a0                  # ...and increase it by the offset

    pop t2, 0                       # retrieve string length
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
        push a1, 0                  # preserver the start address on the stack
        call scroll                 # and scroll
        la t1, screen
        pop a1, 0

1:
    pop a0, 8                       # retrieve pointer to string
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

    stack_free
    ret


# Copies string to screen memory and sets cursor to a new line
# Arguments:
#     a0 - pointer to the beginning of the string
# Returns:
#     a0 - x position of the cursor
#     a1 - y position of the cursor
#     a5 - error code
scr_println:
    stack_alloc
    beqz a0, 1f                        # handle null pointer

    call scr_print                     # Print text at cursor position
    setz a0                            # Set cursor_x to 0
    inc a1                             # increment cursor_y

    li t0, SCREEN_HEIGHT
    blt a1, t0, 2f                     # if cursor_y < SCREEN_HEIGHT jump to end
        dec a1
        push a0, 8
        push a1, 4
        call scroll                    # scroll screen content up
        pop a1, 4
        pop a0, 8
1:                                     # handling null
    li a5, 2                           # set error code
    j 3f
2:  call set_cursor_pos                # set cursor position to a new value
    setz a5                            # exit code
3:
    call get_cursor_pos                # and get it (for return)
    stack_free
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
    stack_alloc 4
    call get_cursor_pos             # get cursor position as x,y coords

    slli t0, a1, 5                  # multiply y by 32
    slli t1, a1, 3                  # multiply y by 8
    add t0, t0, t1                  # sum the above to get y*40
    add a0, a0, t0                  # x+y
    stack_free 4
    ret

get_cursor_address:
    stack_alloc 4
    call get_cursor_offset
    la t0, screen
    add a0, a0, t0
    stack_free 4
    ret


show_cursor:
    stack_alloc 4
    call get_cursor_offset
    la t0, screen
    add t0, t0, a0
    li t1, '_'
    sb t1, (t0)
    stack_free 4
    ret


# Scrolls screen up by one line
# Arguments: a0 - number of lines to scroll (ignored)
# TODO make it respect a0 argument
scroll:
    # copy screen memory one line up
    stack_alloc 4
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
    stack_free 4
    ret


.type scr_backspace, @function
scr_backspace:
    stack_alloc 4
    call get_cursor_pos
    beqz a0, 1f                        # do nothing if cursor_x is 0
    dec a0
    call set_cursor_pos
    call get_cursor_address
    li t0, ' '
    sb t0, (a0)
1:  stack_free 4
    ret


# Prints the content of screen memory to uart
# TODO use uart_putc function rather than direct access to NS16550A
.type print_screen, @function
print_screen:
    stack_alloc 4
    call _print_frame
    la a0, screen                      # set a0 to beginning of screen region
    li a1, UART_BASE
    li t1, SCREEN_WIDTH                # t1 is a  char counter within line
    li t2, SCREEN_HEIGHT               # t2 is a line counter
    li a4, 32                          # space character
    li t0, '|'
    sb t0, (a1)
1:
    lb t0, (a0)                        # load a single byte to t0
    bge t0, a4, 2f                     # if it's printable character jump to 2
    mv t0, a4                          # otherwise replace character with space
2:
    sb t0, (a1)                        # send byte to uart
    dec t1                             # decrement t1
    inc a0                             # increment a1
    beqz t1, 3f
    j 1b                               # jump to 1
3:
    li t0, '|'
    sb t0, (a1)
    li t0, '\n'                        # EOL character
    sb t0, (a1)                        # send to UART
    li t1, SCREEN_WIDTH                # reset t1 to 40
    dec t2                             # decrement t2
    beqz t2, 4f                        # if t2 is zero jump to 3:
    li t0, '|'
    sb t0, (a1)
    j 1b
4:
    setz a0
    setz a1
    call set_cursor_pos
    call _print_frame
    stack_free 4
    ret


_print_frame:
    li t0, '-'
    li t1, 42
    la t2, UART_BASE
1:
    beqz t1, 2f
        sb t0, (t2)
        dec t1
        j 1b
2:
    li t0, '\n'
    sb t0, (t2)
    ret

#--------------------------------------

.section .data

cursor: .half 0
screen: .fill SCREEN_WIDTH*SCREEN_HEIGHT, 1, 32

