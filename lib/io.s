# I/O functions, output-device aware
# for RISC-V OS
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.include "macros.s"
.include "consts.s"

.global printc
.global printw
.global prints
.global println
.global printnum
.global getc
.global read_line

.section .text


fn printc
    stack_alloc

    andi a0, a0, 0xff

    syscall SYSFN_PRINT_CHAR


    stack_free
    ret
endfn


fn printw
    stack_alloc
    push s1, 8
    mv s1, a0

    srli a0, s1, 24
    and a0, a0, 0xff
    call printc

    srli a0, s1, 16
    and a0, a0, 0xff
    call printc

    srli a0, s1, 8
    and a0, a0, 0xff
    call printc

    and a0, s1, 0xff
    call printc

    pop s1, 8
    stack_free
    ret
endfn


fn prints
    stack_alloc
    push a0, 8

    syscall SYSFN_PRINT_STR


    stack_free
    ret
endfn


fn println
    stack_alloc
    push a0, 8

    syscall SYSFN_PRINT_STR
    li a0, '\n'
    syscall SYSFN_PRINT_CHAR

    stack_free
    ret
endfn


fn printnum
    stack_alloc 32
    mv a1, sp
    li a2, 10
    call utoa
    call prints
    stack_free 32
    ret
endfn


fn getc
    stack_alloc 4
    syscall SYSFN_GET_CHAR
    stack_free 4
    ret
endfn


# Reads line from standard input
# Arguments:
#     a0 - string pointer
# Returns:
#     a0 - length of the string
fn read_line
    stack_alloc
    push s1, 8
    push a0, 4
    push s0, 0

    mv s1, a0                          # s1 - pointer to the end of the string

    # call uart_get_status
    mv a0, zero
    and s0, a0, 1                      # s0 - 1 if IRQ for uart is enabled, 0 otherwise

1:
        beqz s0, 2f                    # call wfi if irqs are anbled
            # wfi                      # TODO wfi can't be called in user mode
                                       #      must replaced with idle - sys function
2:
        syscall SYSFN_GET_CHAR
        beqz a0, 1b                    # continue if no key identified

        li t0, 10                      # exit on \r or \n
        beq a0, t0, 3f
        li t0, 13
        beq a0, t0, 3f

        li t0, 127                     # handle backspace
        beq a0, t0, _bcksp

        li t0, 32
        blt a0, t0, 1b                 # ignore special characters
            sb a0, (s1)                # store character
            inc s1                     # increase the pointer
            call printc                # print character
            j 1b

_bcksp:
    pop a1, 4
    beq a1, s1, 1b                     # ignore for empty string
    dec s1
    call _printc_bcksp
    j 1b

3:
    sb zero, (s1)                      # close the string
    pop a0, 4
    sub a0, s1, a0                     # compute string length

    pop s0, 0
    pop s1, 8
    stack_free
    ret
endfn


fn _printc_bcksp
    stack_alloc 4

    li a0, '\b'
    syscall SYSFN_PRINT_CHAR
    li a0, ' '
    syscall SYSFN_PRINT_CHAR
    li a0, '\b'
    syscall SYSFN_PRINT_CHAR

    stack_free 4
    ret
endfn

