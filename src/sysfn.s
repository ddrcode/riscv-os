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

# Runs program from disc
# Arguments
#     a0 - file id
fn sysfn_run
    stack_alloc 64

    call fs_file_info
    lbu t0, 8(sp)
    andi t0, t0, 1
    beqz t0, 1f                        # Exit for non-exec file

    csrr t0, mepc
    la t1, program_return_address
    sw t0, (t1)

    li a0, PROGRAM_RAM

    lw t0, (sp)
    li a1, FLASH1_BASE
    add a1, a1, t0
    addi a1, a1, 512

    lw a2, 4(sp)

    addi t0, a0, -4                    # Set prg start addr - 4
    csrw mepc, t0                      # because IRQ handler increments it by 4

    call memcpy
    j 2f
1:
    li a5, 1
2:
    stack_free 64
    ret
endfn


fn sysfn_exit
    la t1, program_return_address
    lw t0, (t1)
    beqz t0, 1f
        sw zero, (t1)
        csrw mepc, t0
1:
    mv a5, a0
    ret
endfn


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
    .word    sysfn_run                 # 3
    .word    sysfn_exit                # 4
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
    .word    0                         # 23
    .word    0                         # 24
    .word    0                         # 25
    .word    0                         # 26
    .word    0                         # 27
    .word    0                         # 28
    .word    0                         # 29
    .word    fs_file_info              # 30
    .word    fs_read                   # 31
    .word    0                         # 32

program_return_address: .word 0

