.include "config.s"
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
    beqz a0, 0f                          # jump if fn id is 0 (cmd not found)
        li t0, 5                         # compute fn address...
        mul t0, t0, a0
        add t0, t0, t1
        lw t1, (t0)                      # ...addr of function to execute
        lb t2, 4(t0)                     # expected number of arguments
        mv a0, zero
        beqz t2, 2f                      # jump if fn doesn't expect args
            beqz a1, 1f                  # jump if expected argument not provided
            mv a0, a1                    # set input arguent
            j 2f
0:                                       # case when fn id is 0
    li a0, 1                             # set error code to 1 (cmd not found)
    lw t1, (t1)                          # load addr of show_error fn
    j 2f
1:                                       # case when argument is mising
    la t1, fnjumptable                   # set fn to show_errow
    lw t1, (t1)
    li a0, 2                             # set error code (missing argument)
2:                                       # execute sys function
    jalr t1
3:                                       # exit
    pop ra
    ret


.section .rodata

# Jump table to system functions
fnjumptable: .word show_error           # function pointer
             .byte 0                    # number of arguments
             .word clear_screen
             .byte 0
             .word show_date_time
             .byte 0
             .word set_prompt
             .byte 1
             .word println
             .byte 1

