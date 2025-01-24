.global syscall

.section .text

.type syscall, @function
syscall:
    addi sp, sp, -16
    sw ra, 12(sp)

    ecall

    lw ra, 12(sp)
    addi sp, sp, 16
    ret
