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
    # li a0, \arg0
    _convert a0, arg1
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
.if DEBUG > 0
    call debug_missing_ret
.endif
    .cfi_endproc
.endm

.macro syscall, fn_id
   li a5, \fn_id
   ecall
.endm

.macro addr_from_vec, vector, id_reg, res_reg
    la \res_reg, \vector
    slli \id_reg, \id_reg, 2
    add \res_reg, \res_reg, \id_reg
    lw \res_reg, (\res_reg)
.endm

.macro call_cfg_set, cfg, val_reg
    li a0, \cfg
    mv a1, \val_reg
    call cfg_set
.endm


.macro add_device, dev_id, dev_label
    li a0, \dev_id
    la a1, \dev_label
    call device_add
.endm

.endif
