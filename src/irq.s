# Interrupt handlers
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

.include "macros.s"
.include "config.s"

.macro push_all, stack_size
.if \stack_size < 72
    .abort
.endif
    push x15, \stack_size - 8
    push x14, \stack_size - 12
    push x13, \stack_size - 16
    push x12, \stack_size - 20
    push x11, \stack_size - 24
    push x10, \stack_size - 28
    push x9, \stack_size - 32
    push x8, \stack_size - 36
    push x7, \stack_size - 40
    push x6, \stack_size - 44
    push x5, \stack_size - 48
    push x4, \stack_size - 52
    push x3, \stack_size - 56
    push x2, \stack_size - 60
    push x1, \stack_size - 64
    push x0, \stack_size - 68          # why x0? See handle_illegal
.endm

.macro pop_all, stack_size
.if \stack_size < 72
    .abort
.endif
    pop x15, \stack_size - 8
    pop x14, \stack_size - 12
    pop x13, \stack_size - 16
    pop x12, \stack_size - 20
    pop x11, \stack_size - 24
    pop x10, \stack_size - 28
    pop x9, \stack_size - 32
    pop x8, \stack_size - 36
    pop x7, \stack_size - 40
    pop x6, \stack_size - 44
    pop x5, \stack_size - 48
    pop x4, \stack_size - 52
    pop x3, \stack_size - 56
    pop x2, \stack_size - 60
    pop x1, \stack_size - 64
    pop x0, \stack_size - 68          # why x0? See handle_illegal
.endm

.macro irq_stack_alloc, stack_size=80
    csrrw sp, mscratch, sp             # exchange sp with mscratch
    stack_alloc \stack_size            # allocate space on IRQ stack
    push_all \stack_size               # push all registers on the stack
.endm

.macro irq_stack_free, stack_size=80
    pop_all \stack_size                # push all registers on the stack
    stack_free \stack_size             # allocate space on IRQ stack
    csrrw sp, mscratch, sp             # exchange sp with mscratch
.endm

.macro debug, msg
.if DEBUG==1
    la a0, \msg
    call print_debug
.endif
.endm

.section .text



.global irq_init



#----------------------------------------
# IRQ system initialization

fn irq_init
    stack_alloc

    la t0, isr_stack_end               # define interrupt service routine (ISR) stack
    csrw mscratch, t0

    la t0, irq_vector_table            # Load IRQ vector address (must be aligned to 4)
    ori t0, t0, 1                      # Enable with vectorized mode (bit 1 set to 1)
    csrw mtvec, t0                     # Set the vector

    call init_timer                    # enable system timer

    li t0, 0x800
    csrs mie, t0                       # enable hardware interrupts by setting bit 11
    csrs mstatus, 0x8                  # enable global interrupts by setting the MIE field (bit 3)

    stack_free
    ret
endfn


fn init_timer
    stack_alloc
    li a0, SYSTEM_TIMER_INTERVAL
    call _set_mtimecmp

    li t0, 0x80                        # Set MTIE flag (Machine Time Interrupt Enable) - bit 7
    csrs mie, t0

    stack_free
    ret
endfn


# Sets mtimecmp registry to define the time of the next timer IRQ
# it reads the value of mtime (current number of cycles) and increases it
# by the value provided in a0 (32-bit, lower half of a 64-bit number),
# then sets the mtimecmp
# For reference check
# https://five-embeddev.com/riscv-priv-isa-manual/latest-adoc/machine.html#_machine_timer_registers_mtime_and_mtimecmp
# a0 - number of cycles until the next IRQ
fn _set_mtimecmp
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


#----------------------------------------
# Interrupts handling
#
# Direct handlers for individual types of IRQ.
# All should be directly called from IRQ vector
# hence each should handle mscratch and preserving
# registers separately. Each should return with mret


# Handles system timer interrupts
# For not only machine level (IRQ 7),
# but it could be handling supervisor-level too (IRQ 5)
fn handle_timer
    irq_stack_alloc

    li a0, SYSTEM_TIMER_INTERVAL
    call _set_mtimecmp                  # set the next tick

.if OUTPUT_DEV & 0b100
    call video_repaint                 # Refresh the screen (TODO handle with event)
.endif

    # call check_stack                 # check wether the stack is healthy
    irq_stack_free
    mret
endfn


# Handles all externak IRQs, like UART.
# It means in practice it handles PLIC-IRQS
# Hence it uses it's own vector table. As each PLIC config
# is different for each device, the vector is defined in
# src/platforms/$(MACHINE).s file
fn handle_ext_irq
    irq_stack_alloc

    call plic_get_source_id            # load ext IRQ number
    beqz a0, 3f                        # exit if 0
    push a0, 8                         # save it on the stack otherwise

    la t0, external_irq_vector         # compute jump table address
    slli t1, a0, 2                     # t1 = a0 * 4
    add t0, t1, t0

    lw t1, (t0)                        # load handler address
    beqz t1, 2f                        # jump if zero

    jalr t1                            # execute handler
    j 3f
2:
    debug unhandled_ext_irq
3:
    pop a0, 8                          # retrieve IRQ id
    call plic_complete                 # and mark processing as complete
4:
    irq_stack_free
    mret
endfn


# Handles software interrupts. Currently usef for debugging only
fn handle_soft_irq
    irq_stack_alloc
    debug software_irq_msg
    irq_stack_free
    mret
endfn


# Handler for all 'reserved' IRQs. Should never be called
fn unhandled_irq
    irq_stack_alloc
    debug unhandled_irq_msg
    irq_stack_free
    mret
endfn



.align 4
irq_vector_table:
    j handle_exception_vector #  0: Reserved
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
# Exceptions handling
#
# Unlike IRQs, exceptions are synchronous and
# they don't have CPU-handled vector, hence
# the vector is implemented programmatically.
# Also in most of cases the exception hndler should increment
# the PC to the next instruction to avoid an infinite loop.


# Handles exceptions and interrupts
# If bit [31] of mcause is 1 then it's IRQ
.align 4
fn handle_exception_vector
    .set MCAUSE_INT_MASK, 0x80000000   # [31]=1 interrupt, else exception

    irq_stack_alloc

    csrr s1, mcause                    # read the interrupt cause

    li t0, MCAUSE_INT_MASK
    and  t0, s1, t0                    # is it an interrupt (1) or exception (0)?
    bnez t0, 2f

    # handle exceptions
    li t1, 15
    bgt s1, t1, 1f                     # exit if irq id is > 15

    la t1, exceptions_vector           # compute vector address
    slli t0, s1, 2                     # address offset: t0 = s1*4
    add t0, t0, t1                     # final addressL t0 += t1 (base address)

    lw t1, (t0)                        # load handler's address
    beqz t1, 1f                        # exit if handler addr = 0

    addi a0, sp, 12
    jalr t1                            # execute function
1:
    csrr t0, mepc                      # move PC to the next instruction
    addi t0, t0, 4
    csrw mepc, t0
    j 3f

2:  # handle interrupts, although interrupts are handled by vector
    # so if this code is ever executed by an IRQ, means something is wrong
    debug irq_in_exception_handler
3:
    irq_stack_free
    mret                               # return from m-level handler
endfn


# Handler for ecall operations from user mode
# As i's being invoked from handle_exception_vector, it takes
# all params from a pointer to a dump of all registers on the stack.
# Arguments
#     a0 - pointer to registers dump on the stack
# Returns
#     Whatever the system functin returns
# TODO it can be massively simplified (no stack operations)
#      if caught early in handle_exception_vector function
#      and called (or even jumped into) directly
fn handle_syscall
    stack_alloc
    push s1, 8
    mv s1, a0

    # csrs mstatus, 0x8                  # enable interrupts back, no need to block them
                                       # for the time of executing a syscall

    lw a0, 40(s1)                      # fetch value of a0 (x10) from the stack
    lw a1, 44(s1)                      # fetch value of a1 (x10) from the stack
    lw a2, 48(s1)                      # fetch value of a2 (x10) from the stack
    lw a3, 52(s1)                      # fetch value of a3 (x10) from the stack
    lw a4, 56(s1)                      # fetch value of a4 (x10) from the stack
    lw a5, 60(s1)                      # fetch value of a5 (x15) from the stack

    call sys_call

    sw a0, 40(s1)
    sw a1, 44(s1)
    sw a5, 60(s1)

    pop s1, 8
    stack_free
    ret
endfn


fn handle_exception
.if DEBUG==1
    stack_alloc 32
    la a0, exception_message
    call prints

    csrr a0, mcause
    mv a1, sp
    li a2, 10
    call utoa
    mv a0, sp
    call print_debug

    li a0, ' '
    # call printc

    # csrr a0, mepc                    # Faulting address
    csrr a0, mtval                     # Additional fault information
    mv a1, sp
    li a2, 16
    call utoa
    mv a0, sp
    call print_debug

    # call panic
    stack_free 32
.endif
    ret
endfn


# Handles illegal instruction.
# If instruction is recognized as one from M-extension (math)
# it tries to emulate it programatically
# Arguments:
#     a0 - pointer to x0 on the stack (assuming x1 is x0 + 4, etc)
fn handle_illegal
    .set math_mask, (0b1111111<<25) | 0b1111111
    .set math_instr, (1<<25) | 0b110011 # func7=1, opcode=0b0110011
    .set func_mask, 0b111
    stack_alloc
    push s0, 8
    push s1, 4

.if HAS_EXTENSION_M == 0
    csrr s0, mtval                     # On most platforms the mtvl should contain the illegal instruction
    mv s1, a0                          # Store registers dump address in s1

    beqz s0, 4f                        # Finish In case mtval doesn't contain an instruction

    li t2, math_mask                   # test if it is an m-instruction
    and t1, s0, t2
    li t2, math_instr
    bne t1, t2, 4f                     # jump if not m-extension instruction

    srli t1, s0, 12                    # extract function code from the instruction
    andi t1, t1, func_mask

    slli t1, t1, 2                     # compute address of a fallback function
    la t0, m_extension_fallbacks_vector
    add t0, t0, t1
    lw t1, (t0)
    beqz t1, 4f                        # jump if fallback function not provided

    li t2, 15                          # maximum registry id (E extension)

    srli t0, s0, 15                    # extract argument 1 (bits 15-19)
    andi t0, t0, 0b11111               # registry number
    bgt t0, t2, 4f                     # can't handle for reg id > 15
    slli t0, t0, 2                     # multiply registry no by 4
    add t0, s1, t0                     # compute registry val address
    lw a0, (t0)                        # get registry value

    srli t0, s0, 20                    # extract argument 2 (bits 20-24)
    andi t0, t0, 0b11111               # registry number
    bgt t0, t2, 4f                     # can't handle for reg id > 15
    slli t0, t0, 2
    add t0, s1, t0
    lw a1, (t0)

    jalr t1                            # call fallback function

    li t2, 15
    srli t0, s0, 7                     # extract result registry (bits 7-11)
    andi t0, t0, 0b11111               # registry number
    bgt t0, t2, 4f                     # can't handle for reg id > 15
    slli t0, t0, 2
    add t0, s1, t0
    sw a0, (t0)                        # store the result in the registry
    j 5f
.endif

4: # na fallback found (or error occured in a fallback)
    call handle_exception

5: # end
    pop s0, 8
    pop s1, 4
    stack_free
    ret
endfn



# FIXME Doesn't work on virt
fn handle_brk
.if DEBUG==1
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




#----------------------------------------

.section .bss

.align 4
isr_stack:
.skip ISR_STACK_SIZE
.align 4
isr_stack_end:


#----------------------------------------

.section .data
.align 4

exceptions_vector:
    .word    handle_exception          #  0: Instruction address misaligned
    .word    handle_exception          #  1: Instruction access fault
    .word    handle_illegal            #  2: Illegal instruction
    .word    handle_brk                #  3: Breakpoint
    .word    handle_exception          #  4: Load address misaligned
    .word    handle_exception          #  5: Load access fault
    .word    handle_exception          #  6: Store/AMO address misaligned
    .word    handle_exception          #  7: Store/AMO access fault
    .word    handle_syscall            #  8: Environment call from U-mode
    .word    0                         #  9: Environment call from S-mode
    .word    0                         # 10: Reserved
    .word    0                         # 11: Environment call from M-mode
    .word    handle_exception          # 12: Instruction page fault
    .word    handle_exception          # 13: Load page fault
    .word    0                         # 14: Reserved
    .word    handle_exception          # 15: Store/AMO page fault


.if HAS_EXTENSION_M == 0
m_extension_fallbacks_vector:
    .word    0                         #  0: MUL
    .word    0                         #  1: MULH
    .word    0                         #  2: MULHSU
    .word    0                         #  3: MULHU
    .word    div32                     #  4: DIV
    .word    udiv32                    #  5: DIVU
    .word    rem32                     #  6: REM
    .word    urem32                    #  7: REMU
.endif


#----------------------------------------

.section .rodata
.align 4

.if DEBUG==1
    software_irq_msg: .string "Software IRQ detected: "
    exception_message: .string "A system level exception occured. Error code: "
    unhandled_irq_msg: .string "Unhandled IRQ"
    unhandled_ext_irq: .string "Unhandled external IRQ"
    irq_in_exception_handler: .string "Exception handler executed for IRQ"
.endif


