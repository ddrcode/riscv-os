.include "macros.s"

.global printc
.global prints
.global println
.global getc
.global read_line

.section .text

.type printc, @function
printc:
    stack_alloc
    sb a0, (sp)
    sb zero, 1(sp)
    call uart_putc
    mv a0, sp
    lb t0, (a0)
    li t1, '\n'
    bne t0, t1, 1f
        call scr_println
        j 2f
1:  call scr_print
2:  stack_free
    ret

.type prints, @function
prints:
    stack_alloc
    push a0, 8
    call uart_puts
    pop a0, 8
    call scr_print
    stack_free
    ret

.type println, @function
println:
    stack_alloc
    call prints
    li a0, '\n'
    call printc
    stack_free
    ret

.type getc, @function
getc:
    stack_alloc 4
    call uart_getc
    stack_free 4
    ret

# Reads line from standard input
# Arguments:
#     a0 - string pointer
# Returns:
#     a0 - length of the string
.type read_line, @function
read_line:
    stack_alloc
    push s1, 8
    push a0, 4
    mv s1, a0                          # s1 - pointer to the end of the string
1:
        call getc
        beqz a0, 1b                    # continue if no key identified

        li t0, 10                      # exit on \r or \n
        beq a0, t0, 3f
        li t0, 13
        beq a0, t0, 3f

        li t0, 127                     # handle backspace
        beq a0, t0, 2f

        li t0, 32
        blt a0, t0, 1b                 # ignore special characters
            sb a0, (s1)                # store character
            inc s1                     # increase the pointer
2:          call printc                # print character
            j 1b
3:
    sb zero, (s1)                      # close the string
    pop a0, 4
    sub a0, s1, a0                     # compute string length
    pop s1, 8
    stack_free
    ret

