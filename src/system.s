.include "config.s"
.include "macros.s"

.section .text

.global sysinit
.global syscall

.equ SYS_FN_LEN, 4

sysinit:
    ret

syscall:
    push ra
    li t0, SYS_FN_LEN
    bgt a0, t0, 1f
        la t0, fnjumptable
        li t1, 4
        mul t1, t1, a0
        add t0, t0, t1
        lw t1, (t0)
        jalr t1
1:
    pop ra
    ret


.section .rodata

# Jump table to system functions
fnjumptable: .word cmd_not_found
             .word clear_screen
             .word show_date_time

