.macro push, reg, size=4
    addi sp, sp, -\size
    sw \reg, \size-4(sp)
.endm

.macro pop, reg, size=4
    lw \reg, \size-4(sp)
    addi sp, sp, \size
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

