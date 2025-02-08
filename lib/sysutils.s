.include "macros.s"
.include "consts.s"

.global sleep

.section .text

fn sleep
    stack_alloc
    syscall SYSFN_SLEEP
    stack_free
    ret
endfn

