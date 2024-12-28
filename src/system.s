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

.equ SYS_FN_LEN, 4

sysinit:
    ret

# Calls system function
# Arguments:
#     a0 - function id
#     a1 - pointer to arguments (or 0)
syscall:
    push ra
    li t0, SYS_FN_LEN
    bgt a0, t0, 3f                       # exit if fn id is too big
    bltz a0, 3f                          # exit if fn id is negative
    la t1, fnjumptable                   # get addr of jump table
    beqz a0, 1f                          # jump if fn id is 0 (cmd not found)
        li t0, 4                         # compute fn address...
        mul t0, t0, a0
        add t0, t0, t1
        lw t1, (t0)                      # ...addr of function to execute
        mv a0, a1                        # set input arguent
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
    pop ra
    ret


.section .rodata

# Jump table to system functions
fnjumptable: .word show_error           # function pointer
             .word clear_screen
             .word show_date_time
             .word set_prompt
             .word println

