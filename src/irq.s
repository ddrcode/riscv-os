# Interrupt handlers
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "macros.s"
.include "config.s"

.macro push_all, stack_size
    push a0, \stack_size - 8
    push a1, \stack_size - 12
    push a2, \stack_size - 16
    push a3, \stack_size - 20
    push a4, \stack_size - 24
    push a5, \stack_size - 28
    push t0, \stack_size - 32
    push t1, \stack_size - 36
    push t2, \stack_size - 40
    push ra, \stack_size - 44
    push s0, \stack_size - 48
    push s1, \stack_size - 52
.endm

.macro pop_all, stack_size
    pop a0, \stack_size - 8
    pop a1, \stack_size - 12
    pop a2, \stack_size - 16
    pop a3, \stack_size - 20
    pop a4, \stack_size - 24
    pop a5, \stack_size - 28
    pop t0, \stack_size - 32
    pop t1, \stack_size - 36
    pop t2, \stack_size - 40
    pop ra, \stack_size - 44
    pop s0, \stack_size - 48
    pop s1, \stack_size - 52
.endm

.section .text

.global irq_init
.global irq_handler


fn irq_init
    stack_alloc

    la t0, isr_stack_end               # define interrupt service routine (ISR) stack
    csrw mscratch, t0

    la t0, irq_vector_table            # register IRQ handler
    ori t0, t0, 1                      # TODO configure with vectorized mode

    #la t0, irq_handler                 # configure IRQ handler function
    csrw mtvec, t0

    call init_timer                    # enable system timer

    csrr t0, mie                       # enable hardware interrupts
    li t1, 0x800                       # by setting bit 11
    or t0, t0, t1
    csrw mie, t0

    csrr t0, mstatus                   # enable global interrupts
    ori t0, t0, 0x8                    # by setting the MIE field (bit 3)
    csrw mstatus, t0

    stack_free
    ret
endfn


# Handles exceptions and interrupts
# If bit [31] of mcause is 1 then it's IRQ
.type irq_handler, @function
.align 4
fn irq_handler
    .set MCAUSE_INT_MASK, 0x80000000   # [31]=1 interrupt, else exception
    .set MCAUSE_CODE_MASK, 0x7FFFFFFF

    csrrw sp, mscratch, sp             # exchange sp with mscratch
    stack_alloc 64
    push_all 64                        # preserve all registers on the stack

    csrrci zero, mstatus, 0x8          # disable interrupts
    li t0, 0b10000001000
    csrrc s0, mie, t0

    csrr s1, mcause                    # read the interrupt cause

    li t0, MCAUSE_INT_MASK
    and  t0, s1, t0                    # is it an interrupt (1) or exception (0)?
    bnez t0, 2f

    # handle exceptions
    li t1, 15
    bgt s1, t1, 1f                     # exit if irq id is > 15
    li t1, 4                           # compute vector address
    mul t0, s1, t1
    la t1, exceptions_vector
    add t0, t0, t1
    lw t1, (t0)
    beqz t1, 1f                        # exit if handler addr = 0
    jalr t1                            # execute function
1:
    csrr t0, mepc                      # in case of exception move PC to the next instruction
    addi t0, t0, 4
    csrw mepc, t0
    j 3f

2:
    la a0, IRQ_IN_EXCEPTION_HANDLER
    call println
3:
    csrrs zero, mie, s0
    csrrsi zero, mstatus, 0x8          # enable interrupts

    pop_all 64
    stack_free 64
    csrrw sp, mscratch, sp             # exchange sp with mscratch

    mret                               # return from m-level handler
endfn


# Sets mtimecmp registry to define the time of the next timer IRQ
# it reads the value of mtime (current number of cycles) and increases it
# by the value provided in a0 (32-bit, lower half of a 64-bit number),
# then sets the mtimecmp
# For reference check
# https://five-embeddev.com/riscv-priv-isa-manual/latest-adoc/machine.html#_machine_timer_registers_mtime_and_mtimecmp
# a0 - number of cycles until the next IRQ
fn set_mtimecmp
    stack_alloc
    mv a2, a0

    li t0, MTIME
    lw a0, (t0)
    lw a1, 4(t0)
    mv a3, zero
    call uadd64

    li t0, MTIMECMP
    li t1, ~0                          # As the 64-bit addition is not atomic, it must be
    sw t1, (t0)                        # done in a fasion that it's never smaller than the
    sw a1, 4(t0)                       # previous value of mtime. Hence the lower half is first
    sw a0, (t0)                        # set with max value for uint32

    stack_free
    ret
endfn


fn init_timer
    stack_alloc
    li a0, SYSTEM_TIMER_INTERVAL
    call set_mtimecmp

    csrr t0, mie                       # MTIE is bit 7 in mie
    li t1, 0x80                        # Set MTIE flag (Machine Time Interrupt Enable)
    or t0, t0, t1
    csrw mie, t0

    stack_free
    ret
endfn


fn handle_timer
    stack_alloc
    li a0, SYSTEM_TIMER_INTERVAL
    call set_mtimecmp                  # set the next tick

.if OUTPUT_DEV & 0b100
    call video_repaint                 # Refresh the screen
.endif

    # call check_stack                 # check wether the stack is healthy

    stack_free
    mret
endfn


fn handle_exception
.if debug==1
    stack_alloc 32
    la a0, exception_message
    call prints

    csrr a0, mcause
    mv a1, sp
    li a2, 10
    call utoa
    mv a0, sp
    call prints

    li a0, ' '
    call printc

    # csrr a0, mepc                    # Faulting address
    csrr a0, mtval                     # Additional fault information
    mv a1, sp
    li a2, 16
    call utoa
    mv a0, sp
    call println

    # call panic
    stack_free 32
.endif
    ret
endfn


fn handle_math
    stack_alloc

    stack_free
endfn


fn handle_ext_irq
    stack_alloc
    call plic_get_source_id            # load ext IRQ number
    beqz a0, 3f                        # exit if 0
    push a0, 8                         # save it on the stack otherwise

    la t0, external_irq_vector         # compute jump table address
    li t1, 4
    mul t1, t1, a0
    add t0, t1, t0

    lw t1, (t0)                        # load handler address
    beqz t1, 2f                        # jump if zero

    jalr t1                            # execute handler
    j 3f
2:
.if debug==1
    la a0, unhandled_ext_irq
    call println
.endif
3:
    pop a0, 8                          # retrieve IRQ id
    call plic_complete                 # and mark processing as complete
4:
    stack_free
    mret
endfn


fn handle_soft_irq
.if debug==1
    stack_alloc
    la a0, irq_message
    call println
    stack_free
.endif
    mret
endfn


# FIXME Doesn't work on virt
fn handle_brk
.if debug==1
    stack_alloc 32
    mv t0, a0
    mv t1, a1
    mv t2, a2

    mv a1, sp
    li a2, 16
    call utoa

    mv a0, sp
    call prints

    stack_free 32
.endif
    ret
endfn


fn unhandled_irq
.if debug==1
.endif
    mret
endfn


irq_vector_table:
    j irq_handler             #  0: Reserved
    j unhandled_irq           #  1: Supervisor software interrupt
    j unhandled_irq           #  2: Reserved
    j handle_soft_irq         #  3: Machine software interrupt
    j unhandled_irq           #  4: Reserved
    j unhandled_irq           #  5: Supervisor timer interrupt
    j unhandled_irq           #  6: Rserved
    j handle_timer            #  7: Machine timer interrupt
    j unhandled_irq           #  8: Reserved
    j unhandled_irq           # 19: Supervisor external interrupt
    j unhandled_irq           # 10: Reserved
    j handle_ext_irq          # 11: Machine external interrupt
    j unhandled_irq           # 12: Reserved
    j unhandled_irq           # 13: Reserved
    j unhandled_irq           # 14: Reserved
    j unhandled_irq           # 15: Reserved


#----------------------------------------

.section .bss

.align 4

isr_stack:
.skip 1024
isr_stack_end:


#----------------------------------------

.section .data
.align 4

exceptions_vector:
    .word    handle_exception          #  0: Instruction address misaligned
    .word    handle_exception          #  1: Instruction access fault
    .word    handle_exception          #  2: Illegal instruction
    .word    handle_brk                #  3: Breakpoint
    .word    handle_exception          #  4: Load address misaligned
    .word    handle_exception          #  5: Load access fault
    .word    handle_exception          #  6: Store/AMO address misaligned
    .word    handle_exception          #  7: Store/AMO access fault
    .word    syscall                   #  8: Environment call from U-mode
    .word    syscall                   # 19: Environment call from S-mode
    .word    0                         # 10: Reserved
    .word    syscall                   # 11: Environment call from M-mode
    .word    handle_exception          # 12: Instruction page fault
    .word    handle_exception          # 13: Load page fault
    .word    0                         # 14: Reserved
    .word    handle_exception          # 15: Store/AMO page fault




#----------------------------------------

.section .rodata
.align 4

.if debug==1
irq_message: .string "Software IRQ detected: "
exception_message: .string "A system level exception occured. Error code: "
unhandled_ext_irq: .string "Unhandled external IRQ"
IRQ_IN_EXCEPTION_HANDLER: .string "Exception handler executed for IRQ"
.endif

