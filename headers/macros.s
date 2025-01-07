.macro stack_alloc, size=16
    addi sp, sp, -\size
    sw ra, \size-4(sp)
.endm

.macro stack_free, size=16
    lw ra, \size-4(sp)
    addi sp, sp, \size
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

