.include "config.s"
.include "macros.s"

.section .text

.global sysinit
.global syscall

.equ SYS_FN_LEN, 4

sysinit:
    push ra

    la a0, cmd_not_found
    li a1, 0
    call add_sys_fn

    la a0, clear_screen
    li a1, 1
    call add_sys_fn

    pop ra
    ret

add_sys_fn:
    la t0, fns
    li t1, 4
    mul a1, a1, t1
    add t0, t0, a1
    sw a0, (t0)
    ret

syscall:
    push ra
    li t0, SYS_FN_LEN
    bgt a0, t0, 1f
    la t0, fns
    add t0, t0, a0
    lw t0, (t0)
    jalr t0
1:
    pop ra
    ret

.section .data

fns: .fill (SYS_FN_LEN+1)*4, 1, 0
