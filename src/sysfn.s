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

    mv a1, sp
    call fs_file_info
    lbu t0, 8(sp)
    andi t0, t0, 1
    beqz t0, 1f                        # Exit for non-exec file

    csrr t0, mepc
    la t1, program_return_address      # FIXME state is not required, just pass the arg back to cmd_run
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


fn sysfn_sleep
    mv a1, a0

    csrr a0, mepc                      # the function returns return address from pause
    addi a0, a0, 4
    mv a5, zero                        # and no error code

    la t0, sys_sleep                   # return from the trap to pause function
    addi t0, t0, -4
    csrw mepc, t0

    li t0, 0b11                        # in machine mode
    slli t0, t0, 11
    csrs mstatus, t0

    ret
endfn


fn sysfn_idle
    csrr a0, mepc                      # the function returns return address from idle
    addi a0, a0, 4
    mv a5, zero                        # and no error code

    la t0, idle                        # return from the trap to idle function
    addi t0, t0, -4
    csrw mepc, t0

    li t0, 0b11                        # in machine mode
    slli t0, t0, 11
    csrs mstatus, t0

    ret
endfn


fn sysfn_get_drv_config
    stack_alloc
    call hal_get_config
    mv a5, zero
    stack_free
    ret
endfn


fn sysfn_get_secs_from_epoch
    stack_alloc
    li a0, DEV_RTC_0
    call device_get
    li a5, ERR_NOT_SUPPORTED
    beqz a0, 1f

    call rtc_get_secs_from_epoch
    setz a5

1:
    stack_free
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


fn sysfn_putc
    stack_alloc
    push a0, 8

    li a0, CFG_STD_OUT
    call cfg_get

    pop a1, 8
    call uart_putc

    stack_free
    ret
endfn

fn sysfn_puts
    stack_alloc
    push a0, 8

    li a0, CFG_STD_OUT
    call cfg_get

    pop a1, 8
    call uart_puts

    stack_free
    ret
endfn

fn sysfn_getc
    stack_alloc
    # push a0, 8

    li a0, CFG_STD_IN
    call cfg_get

    # pop a1, 8
    call uart_getc

    stack_free
    ret
endfn

#----------------------------------------

.section .data

sysfn_vector:
    .word    0                         #  0
    .word    sysfn_sleep               #  1
    .word    sysfn_idle                #  2
    .word    sysfn_run                 #  3
    .word    sysfn_exit                #  4
    .word    cfg_get                   #  5
    .word    sysfn_get_drv_config      #  6
    .word    0                         #  7
    .word    0                         #  8
    .word    0                         #  9
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
    .word    sysfn_getc                # 20
    .word    sysfn_putc                # 21
    .word    sysfn_puts                # 22
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
    .word    0                         # 33
    .word    0                         # 34
    .word    0                         # 35
    .word    0                         # 36
    .word    0                         # 37
    .word    0                         # 38
    .word    0                         # 39
    .word    fb_info                   # 40
    .word    fb_get_cursor             # 41
    .word    fb_set_cursor             # 42
    .word    0                         # 43
    .word    0                         # 44
    .word    0                         # 45
    .word    0                         # 46
    .word    0                         # 47
    .word    0                         # 48
    .word    0                         # 49
    .word    video_set_screencode      # 50
    .word    video_reset               # 51
    .word    video_switch_mode         # 52
    .word    0                         # 53

program_return_address: .word 0

