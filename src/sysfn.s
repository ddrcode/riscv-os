# System function
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.include "macros.s"
.include "consts.s"
.include "config.s"

.global sysfn_vector

#----------------------------------------

.section .text

fn sysfn_get_secs_from_epoch
.ifdef RTC_BASE
    stack_alloc
    call rtc_time_in_sec
    setz a5
    stack_free
.else
    li a5, ERR_NOT_SUPPORTED
.endif
    ret
endfn


fn sysfn_get_date
    stack_alloc
    call sysfn_get_secs_from_epoch
    bnez a5, 1f
    call get_date
    mv a5, zero
1:
    stack_free
    ret
endfn


fn sysfn_get_time
    stack_alloc
    call sysfn_get_secs_from_epoch
    bnez a5, 1f
    call get_time
    mv a5, zero
1:
    stack_free
    ret
endfn

#----------------------------------------


.section .data

sysfn_vector:
    .word    0                         # 0
    .word    0                         # 1
    .word    0                         # 2
    .word    0                         # 3
    .word    0                         # 4
    .word    0                         # 5
    .word    0                         # 6
    .word    0                         # 7
    .word    0                         # 8
    .word    0                         # 9
    .word    sysfn_get_secs_from_epoch # 10
    .word    sysfn_get_date            # 11
    .word    0                         # 12
    .word    sysfn_get_time            # 13
    .word    0                         # 14
    .word    0                         # 15
    .word    0                         # 16
    .word    0                         # 17
    .word    0                         # 18
    .word    0                         # 19
    .word    uart_getc                 # 20
    .word    uart_putc                 # 21
    .word    uart_puts                 # 22
