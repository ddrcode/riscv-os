.include "consts.s"
.include "macros.s"


.global main

.section .text

main:
    stack_alloc 32

    syscall SYSFN_GET_SECS_FROM_EPOCH
    bnez a5, 1f                        # finish on error (i.e. no RTC)

    mv a1, sp
    call date_time_to_str
    mv a0, sp
    call println

    j 2f
1:
    la a0, rtc_error
    call println
2:
    setz a0
    stack_free 32
    ret


.section .rodata

rtc_error: .string "Couldn't obtain RTC data"

