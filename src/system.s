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
.global syscall
.global check_stack
.global panic


.type sysinit, @function
sysinit:
    stack_alloc 4
    call plic_init
    call uart_init
.if OUTPUT_DEV & 0b100
    call video_init
.endif
    stack_free 4
    ret

# Calls system function
# Arguments:
#     a0 - pointer to arguments (or 0)
#     a5 - function id (as per ilp32e ABI)
.type syscall, @function
syscall:
    stack_alloc 4
    li t0, SYS_FN_LEN
    bgt a5, t0, 3f                       # exit if fn id is too big
    bltz a5, 3f                          # exit if fn id is negative
    la t1, fnjumptable                   # get addr of jump table
    beqz a5, 1f                          # jump if fn id is 0 (cmd not found)
        li t0, 4                         # compute fn address...
        mul t0, t0, a5
        add t0, t0, t1
        lw t1, (t0)                      # ...addr of function to execute
        j 2f
1:                                       # case when fn id is 0
    li a0, 1                             # set error code to 1 (cmd not found)
    lw t1, (t1)                          # load addr of show_error fn
2:                                       # execute sys function
    jalr t1
    beqz a5, 3f                          # finish if return code is 0
    mv a0, a5
    call show_error                      # otherwise show error
3:                                       # exit
    stack_free 4
    ret


.type check_stack, @function
check_stack:
    stack_alloc 4
    la t0, __stack_top
    li t1, STACK_SIZE
    sub t0, t0, t1
    bgt sp, t0, 1f

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

