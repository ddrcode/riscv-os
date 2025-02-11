# (Text) Screen handling functions
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.include "macros.s"
.include "config.s"
.include "consts.s"

.global scr_init
.global clear_screen
.global scr_print
.global scr_println
.global show_cursor
.global get_cursor_pos
.global set_cursor_pos
.global print_screen
.global scr_backspace
.global scr_get_size

.global screen

.macro screen_addr, reg
    la \reg, screen_ptr
    lw \reg, (\reg)
.endm

.macro get_cursor
    syscall SYSFN_FB_GET_CURSOR
.endm

.macro set_cursor
    syscall SYSFN_FB_SET_CURSOR
.endm

.section .text

fn scr_init
    stack_alloc 16
    mv a0, zero
    mv a1, sp
    syscall SYSFN_FB_INFO
    la t0, screen_ptr
    sw a0, (t0)
    stack_free 16
    ret
endfn


fn clear_screen
    stack_alloc 4
    screen_addr a0
    li a1, SCREEN_WIDTH*SCREEN_HEIGHT
    li a2, ' '
    call memfill

    setz a0
    setz a1
    call set_cursor_pos

    setz a5                            # set exit code
    stack_free 4
    ret
endfn


fn scr_get_size
    li a0, SCREEN_WIDTH
    li a1, SCREEN_HEIGHT
    ret
endfn


# Copies string to screen memory at the cursor position
# Arguments:
#     a0 - a pointer to the beginning of the string
# Returns:
#     a0 - x position of the cursor
#     a1 - y position of the cursor
fn scr_print
    stack_alloc                     # prepare the stack
    push a0, 8
    push a1, 4
    call strlen                     # get string length
    push a0, 0                      # and push it to the stack

    call get_cursor_offset          # get cursor offset
    screen_addr a1                  # load screen address..
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
        divu a0, t0, a0
        mul t0, t0, a0              # and adjust the start address (a1) accordingly
        sub a1, a1, t0
        push a1, 0                  # preserver the start address on the stack
        call scroll                 # and scroll
        screen_addr t1
        pop a1, 0

1:
    pop a0, 8                       # retrieve pointer to string
2:
    lbu t0, (a0)                    # Load a single byte of a string
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
endfn


# Copies string to screen memory and sets cursor to a new line
# Arguments:
#     a0 - pointer to the beginning of the string
# Returns:
#     a0 - x position of the cursor
#     a1 - y position of the cursor
#     a5 - error code
fn scr_println
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
endfn


# Sets cursor position
# a0 - cursor x position
# a1 - cursor y position (remains unchanged)
# returns cursor 16-bit number representing cursor in a0
# TODO check screen boundaries
fn set_cursor_pos
    stack_alloc
    mv a2, a1
    mv a1, a0
    mv a0, zero
    set_cursor
    stack_free
    ret
endfn


fn set_cursor_pos_from_offset
    stack_alloc
    li t0, SCREEN_WIDTH
    divu a2, a0, t0
    remu a1, a0, t0
    setz a0
    set_cursor
    srai a1, a0, 8
    andi a0, a0, 0xff
    stack_free
    ret
endfn


# Returns cursor position
# Arguments: none
# Returns:
#    a0 - x position
#    a1 - y position
fn get_cursor_pos
    stack_alloc
    mv a0, zero
    get_cursor
    srai a1, a0, 8
    andi a0, a0, 0xff
    stack_free
    ret
endfn


# Computes cursor offset - how many bytes it's away from the
# begining of the screen memory.
# Formula: 40*y+x
# Arguments: none
# Returns:
#     a0: offset
fn get_cursor_offset
    stack_alloc 4
    call get_cursor_pos             # get cursor position as x,y coords

    slli t0, a1, 5                  # multiply y by 32
    slli t1, a1, 3                  # multiply y by 8
    add t0, t0, t1                  # sum the above to get y*40
    add a0, a0, t0                  # x+y
    stack_free 4
    ret
endfn


fn get_cursor_address
    stack_alloc 4
    call get_cursor_offset
    screen_addr t0
    add a0, a0, t0
    stack_free 4
    ret
endfn


fn show_cursor
    stack_alloc 4
    call get_cursor_offset
    screen_addr t0
    add t0, t0, a0
    li t1, '_'
    sb t1, (t0)
    stack_free 4
    ret
endfn


# Scrolls screen up by one line
# Arguments: a0 - number of lines to scroll (ignored)
# TODO make it respect a0 argument
fn scroll
    # copy screen memory one line up
    stack_alloc 4
    screen_addr a0
    addi a1, a0, SCREEN_WIDTH
    li a2, SCREEN_WIDTH*(SCREEN_HEIGHT-1)
    call memcpy

    # fill the last line with spaces
    li a1, SCREEN_WIDTH
    li a2, 32
    call memfill

    # adjust cursor position (one line up)
    call get_cursor_pos
    beqz a1, 1f
        dec a1
        call set_cursor_pos

1:
    stack_free 4
    ret
endfn


fn scr_backspace
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
endfn


#--------------------------------------

.section .data

# FIXME temporary solution. Use fb functions instead
screen_ptr: .word 0
