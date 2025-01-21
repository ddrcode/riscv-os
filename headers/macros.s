.ifndef __MACROS_S__
.equ __MACROS_S__, 1

.include "config.s"

.macro stack_alloc, size=MIN_STACK_ALLOC_CHUNK
.if \size < MIN_STACK_ALLOC_CHUNK
    addi sp, sp, -MIN_STACK_ALLOC_CHUNK
.else
    addi sp, sp, -\size
.endif
    sw ra, \size-4(sp)
.endm

.macro stack_free, size=MIN_STACK_ALLOC_CHUNK
    lw ra, \size-4(sp)
.if \size < MIN_STACK_ALLOC_CHUNK
    addi sp, sp, MIN_STACK_ALLOC_CHUNK
.else
    addi sp, sp, \size
.endif
.endm

.macro push, reg, pos
    sw \reg, \pos(sp)
.endm

.macro pop, reg, pos
    lw \reg, \pos(sp)
.endm

.macro pushb, reg, pos
    sb \reg, \pos(sp)
.endm

.macro popb, reg, pos
    lbu \reg, \pos(sp)
.endm

.macro inc, reg
    addi \reg, \reg, 1
.endm

.macro dec, reg
    addi \reg, \reg, -1
.endm

.macro setz, reg
    mv \reg, zero
.endm

.macro callfn, name, arg0, arg1=0, arg2=0, arg3=0, arg4=0, arg5=0
    li a0, \arg0
    li a1, \arg1
    li a2, \arg2
    li a3, \arg3
    li a4, \arg4
    li a5, \arg5
    call \name
.endm


.macro fn, name
    .type \name, @function
    .align 2
    \name:
    .cfi_startproc
.endm

.macro endfn
    .cfi_endproc
.endm

.macro syscall, fn_id
    li a5, \fn_id
    ecall
.endm

.endif
