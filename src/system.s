# System funtions of RISC-V OS
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "config.s"
.include "consts.s"
.include "macros.s"

.section .text

.global sysinit
.global sys_call
.global check_stack
.global panic
.global idle
.global sys_sleep

#------------------------------------------------------------------------------

fn sysinit
    stack_alloc

.if PMP_ENABLED > 0
    call setup_pmp
.endif

    li a0, INFO_OUTPUT_DEV
    li a1, OUTPUT_DEV
    call cfg_set

.if OUTPUT_DEV & 0b100
    call video_init
.endif

    stack_free
    ret
endfn


# Setup phisical memory protection (PMP)
# At this stage the PMP is configured that it gives full access to RAM
# to the User Mode (U), and the rest of memory space is reserved to
# the machine-mode (M) only. Any access to devices must happen
# via drivers (accessed from syscalls)
# There is an optional config flag that locks PMP registers,
# making M-mode unable to reconfigure it until rest
.if PMP_CUSTOM_CONFIG == 0
fn setup_pmp
    li t0, (RAM_START_ADDR / 2) >> 2   # region 0 - addresses before RMA
    csrw pmpaddr0, t0                  # if RAM starts at zero, the region is zero-size

    li t0, (RAM_START_ADDR + (RAM_END_ADDR - RAM_START_ADDR) / 2) >> 2
    csrw pmpaddr1, t0                  # region 1 - RAM

    not t0, zero                       # region 2 - everything above RAM up to 0xffffffff
    csrw pmpaddr2, t0

.if RAM_START_ADDR == 0
    mv t2, zero                        # if RAM starts at 0, ignore the pre-RAM region
.else
    li t2, 0b11100                     # Make pre-RAM accessible to machine mode only
.endif

    li t0, 0b11111                     # RAM: give RWX rights to user mode
    slli t1, t0, 8
    or t2, t2, t1

    li t0, 0b01100                     # post-ram: access reserved to Machine only
    slli t1, t0, 16
    or t2, t2, t1

.if PMP_LOCKED > 0                     # If locking is enabled set bit 7 to 1 for
    li t0, 0x00808080                  # all three regions
    or t2, t2, t0
.endif

    csrw pmpcfg0, t2                   # save permissions
    ret
endfn
.endif


# Calls system function
# Arguments:
#     a0-a4 - function arguments
#     a5 - function id (as per ilp32e ABI)
fn sys_call
    stack_alloc 4
    li t0, SYSFN_LAST_FN_ID
    bgt a5, t0, 1f                     # error if fn id is too big
    blez a5, 1f                        # error if fn id <= 0

    addr_from_vec sysfn_vector, a5, t0 # fetch function address from vector
    beqz t0, 1f                        # error if fn not found (addr 0)

        jalr t0                        # execute system function
        j 2f

1:  # error handling
    li a5, ERR_NOT_SUPPORTED

2:  # end
    stack_free 4
    ret
endfn


fn check_stack
    stack_alloc 4
    la t0, __stack_top
    li t1, STACK_SIZE
    sub t0, t0, t1

    bgtu sp, t0, 1f

    li a0, ERR_STACK_OVERFLOW
    call show_error
    call panic

1:  stack_free 4
    ret
endfn


fn panic
    stack_alloc 4

    csrc mstatus, 0x8                  # Disable interrupts

    la a0, kernel_panic                # Display kernel panic msg
    call println
1:
    j 1b                               # Enter infinite loop
    stack_free 4
    ret
endfn


# Waits until some action (IRQ) happens
# it ignores timer interrupts and exceptions
# Arguments:
#     a0 - return adress (PC)
fn idle
    csrs mstatus, 0x8                  # enable global interrupts by setting the MIE field (bit 3)
    li t1, 0x80000000
    li t2, 0x80000007
1:
    wfi
        csrr t0, mcause
        beq t0, t2, 1b                 # loop in case of timer interrupt
        bgtu t0, t1, 2f                # finish if any other IRQ
        j 1b

2:
    csrw mepc, a0                      # set the return address

    li t0, 0b11                        # set PCP field of mstatus to 00 (User mode)
    slli t0, t0, 11
    csrc mstatus, t0

    mret                               # return to user mode
endfn


# Sleep function
# Arguments
#    a0 - return address
#    a1 - sleep time in ms
fn sys_sleep
    csrs mstatus, 0x8                  # enable global interrupts by setting the MIE field (bit 3)
    stack_alloc
    push a0, 8

    li t0, CPU_FREQUENCY
    li t1, 2
    mul t0, t0, a1
    div t0, t0, t1

1:
    nop
    dec t0
    bnez t0, 1b

#     li t0, 16                          # compute how many timer IRQs to wait
#     divu t0, a1, t0                    # assuming the frequency is 16ms
#
#     li t2, 0x80000007                  # timer IRQ code
# 1:
#     wfi
#         csrr t1, mcause
#         bne t1, t2, 1b                 # if it's not time IRQ, go back
#         dec t0
#         bnez t0, 1b

    pop a0, 8
    csrw mepc, a0                      # set the return address

    li t0, 0b11                        # set PCP field of mstatus to 00 (User mode)
    slli t0, t0, 11
    csrc mstatus, t0
    stack_free
    mret
endfn

#------------------------------------------------------------------------------

.section .rodata

kernel_panic: .string "Kernel panic!"
