# System funtions of RISC-V OS
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "config.s"
.include "consts.s"
.include "macros.s"

.section .text

.global sysinit
.global sys_call
.global check_stack
.global panic


.type sysinit, @function
sysinit:
    stack_alloc 4
.if OUTPUT_DEV & 0b100
    call video_init
.endif
    stack_free 4
    ret


# Calls system function
# Arguments:
#     a0-a4 - function arguments
#     a5 - function id (as per ilp32e ABI)
fn sys_call
    stack_alloc 4
    li t0, SYSFN_LAST_FN_ID
    bgt a5, t0, 1f                       # error if fn id is too big
    blez a5, 1f                          # error if fn id <= 0

    addr_from_vec sysfn_vector, a5, t0   # fetch function address from vector
    beqz t0, 1f                          # error if fn not found (addr 0)

        jalr t0                          # execute system function
        j 2f

1:  # error handling
    li a5, ERR_NOT_SUPPORTED

2:  # end
    stack_free 4
    ret
endfn


.type check_stack, @function
check_stack:
    stack_alloc 4
    la t0, __stack_top
    li t1, STACK_SIZE
    sub t0, t0, t1

    bgtu sp, t0, 1f

    li a0, ERR_STACK_OVERFLOW
    call show_error
    call panic

1:  stack_free 4
    ret


.type panic, @function
panic:
    stack_alloc 4
    la a0, kernel_panic
    call println
    stack_free 4
    ret

#------------------------------------------------------------------------------

.section .rodata

# Jump table to system functions
# TODO function address size could be half-words
fnjumptable: .word show_error
             .word clear_screen
             .word show_date_time
             .word set_prompt
             .word println
             .word print_screen

kernel_panic: .string "Kernel panic!"

