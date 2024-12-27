.macro push, reg
    addi sp, sp, -4
    sw \reg, (sp)
.endm

.macro pop, reg
    lw \reg, (sp)
    addi sp, sp, 4
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

