.include "macros.s"

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


.type irq_init, @function
.align 4
irq_init:
    la t0, isr_stack_end               # define interrupt service routine (ISR) stack
    csrw mscratch, t0

    # la t0, irq_vector_table                 # register IRQ handler
    # ori t0, t0, 1                    # TODO configure with vectorized mode

    la t0, irq_handler                 # configure IRQ handler function
    csrw mtvec, t0

    csrr t0, mie                       # enable hardware interrupts
    li t1, 0x800                       # by setting bit 11
    or t0, t0, t1
    csrw mie, t0

    csrr t0, mstatus                   # enable global interrupts
    ori t0, t0, 0x8                    # by setting the MIE field (bit 3)
    csrw mstatus, t0

    ret


# Handles exceptions and interrupts
# If bit [31] of mcause is 1 then it's IRQ
.type irq_handler, @function
.align 4
irq_handler:
    .set MCAUSE_INT_MASK, 0x80000000   # [31]=1 interrupt, else exception
    .set MCAUSE_CODE_MASK, 0x7FFFFFFF

    csrrw sp, mscratch, sp             # exchange sp with mscratch
    stack_alloc 64
    push_all 64                        # preserve all registers on the stack

    csrrci zero, mstatus, 0x8             # disable interrupts
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

2:  # handle IRQs
    li t0, MCAUSE_CODE_MASK
    and t0, s1, t0
    li t1, 15
    bgt t0, t1, 3f                     # exit if irq id is > 15
    li t1, 4                           # compute vector address
    mul t0, t0, t1
    la t1, irq_vector
    add t0, t0, t1
    lw t1, (t0)
    beqz t1, 3f                        # exit if handler addr = 0
    jalr t1                            # execute function

3:
    csrrs zero, mie, s0
    csrrsi zero, mstatus, 0x8             # enable interrupts

    pop_all 64
    stack_free 64
    csrrw sp, mscratch, sp             # exchange sp with mscratch

    mret                               # return from m-level handler


.type handle_exception, @function
handle_exception:
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

    # csrr a0, mepc     # Faulting address
    csrr a0, mtval    # Additional fault information
    mv a1, sp
    li a2, 16
    call utoa
    mv a0, sp
    call println

    # call panic
    stack_free 32
    ret


.type handle_irq, @function
handle_irq:
    stack_alloc 32
    la a0, irq_message
    call prints

    csrr a0, mcause
    li t0, MCAUSE_CODE_MASK
    and a0, a0, t0
    mv a1, sp
    li a2, 10
    call utoa
    mv a0, sp
    call println
    stack_free 32
    ret


.type handle_brk, @function
handle_brk:
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


irq_vector:
    .word    0                         #  0: Reserved
    .word    0                         #  1: Supervisor software interrupt
    .word    0                         #  2: Reserved
    .word    handle_irq                #  3: Machine software interrupt
    .word    0                         #  4: Reserved
    .word    0                         #  5: Supervisor timer interrupt
    .word    0                         #  6: Rserved
    .word    0                         #  7: Machine timer interrupt
    .word    0                         #  8: Reserved
    .word    0                         # 19: Supervisor external interrupt
    .word    0                         # 10: Reserved
    .word    handle_irq                # 11: Machine external interrupt
    .word    0                         # 12: Reserved
    .word    0                         # 13: Reserved
    .word    0                         # 14: Reserved
    .word    0                         # 15: Reserved


#----------------------------------------

.section .rodata
.align 4

irq_message: .string "IRQ detected: "
exception_message: .string "A system level exception occured. Error code: "
