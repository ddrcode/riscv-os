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

    call scr_get_size
    mul a1, a0, a1                     # a1 = width * height

    screen_addr a0
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
    li a0, CFG_SCREEN_DIMENSIONS
    syscall SYSFN_GET_CFG
    li t0, 0xffff
    srli a1, a0, 16
    and a0, a0, t0
    ret
endfn


# Copies string to screen memory at the cursor position
# Arguments:
#     a0 - a pointer to the beginning of the string
# Returns:
#     a0 - x position of the cursor
#     a1 - y position of the cursor
fn scr_print
    stack_alloc 32
    push s0, 24
    push s1, 20
    push a0, 8
    push a1, 4
    call strlen                     # get string length
    push a0, 0                      # and push it to the stack

    call scr_get_size
    mv s0, a0
    mv s1, a1

    call get_cursor_offset          # get cursor offset
    screen_addr a1                  # load screen address..
    mv t1, a1                       # copy screen address to t1
    add a1, a1, a0                  # ...and increase it by the offset

    pop t2, 0                       # retrieve string length
    add t2, t2, a1                  # and compute the end address

    mul t0, s0, s1                  # number of bytes in the screen buffer (width*height)
    add t0, t0, t1                  # compute the end address of the screen

    ble t2, t0, 1f                  # skip if string fits on the screen, scroll otherwise
        sub t0, t2, t0              # compute how many lines to scroll...
        mv a0, s0                   # a0 = screen buffer width
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

    pop s0, 24
    pop s1, 20
    stack_free 32
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

    push a0, 8
    push s1, 4

    call scr_get_size
    mv s1, a1

    pop a0, 8
    call scr_print                     # Print text at cursor position
    setz a0                            # Set cursor_x to 0
    inc a1                             # increment cursor_y

    blt a1, s1, 2f                     # if cursor_y < SCREEN_HEIGHT jump to end
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

    pop s1, 4
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


# Arguments
#     a0 - offset
fn set_cursor_pos_from_offset
    stack_alloc
    push a0, 8

    call scr_get_size
    mv t0, a0                          # Screen width

    pop a0, 8
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
    stack_alloc

    call scr_get_size
    push a0, 8

    call get_cursor_pos             # get cursor position as x,y coords

    pop t0, 8
    mul t0, t0, a1
    add a0, a0, t0                  # x+y
    stack_free
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
    stack_alloc
    push s0, 8
    push s1, 4

    call scr_get_size
    mv s0, a0
    mv s1, a1

    # copy screen memory one line up
    screen_addr a0
    add a1, a0, s0
    addi t0, s1, -1
    mul a2, s0, t0                     # a2 = width * (height-1)
    call memcpy

    # fill the last line with spaces
    mv a1, s0
    li a2, ' '
    call memfill

    # adjust cursor position (one line up)
    call get_cursor_pos
    beqz a1, 1f
        dec a1
        call set_cursor_pos

1:
    pop s0, 8
    pop s1, 4
    stack_free
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
