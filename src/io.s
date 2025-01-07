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

.if OUTPUT_DEV & 0b10
    call uart_putc
.endif

.if OUTPUT_DEV & 1
    mv a0, sp
    lbu t0, (a0)
    li t1, '\n'
    bne t0, t1, 1f
        call scr_println
        j 2f
1:  call scr_print
2:
.endif

.if OUTPUT_DEV & 0b100
    call video_repaint
.endif

    stack_free
    ret


.type prints, @function
prints:
    stack_alloc
    push a0, 8

.if OUTPUT_DEV & 0b10
    call uart_puts
.endif

.if OUTPUT_DEV & 1
    pop a0, 8
    call scr_print
.endif

.if OUTPUT_DEV & 0b100
    call video_repaint
.endif
    stack_free
    ret


.type println, @function
println:
    stack_alloc
    push a0, 8

.if OUTPUT_DEV & 0b10
    call uart_puts
    li a0, '\n'
    call uart_putc
.endif

.if OUTPUT_DEV & 1
    pop a0, 8
    call scr_println
.endif

.if OUTPUT_DEV & 0b100
    call video_repaint
.endif
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
        beq a0, t0, _bcksp

        li t0, 32
        blt a0, t0, 1b                 # ignore special characters
            sb a0, (s1)                # store character
            inc s1                     # increase the pointer
            call printc                # print character
            j 1b

_bcksp:
    pop a1, 4
    beq a1, s1, 1b                     # ignore for empty string
    dec s1
    call _printc_bcksp
    j 1b

3:
    sb zero, (s1)                      # close the string
    pop a0, 4
    sub a0, s1, a0                     # compute string length
    pop s1, 8
    stack_free
    ret


_printc_bcksp:
    stack_alloc 4

.if OUTPUT_DEV & 0b10
    li a0, '\b'
    call uart_putc
    li a0, ' '
    call uart_putc
    li a0, '\b'
    call uart_putc
.endif

.if OUTPUT_DEV & 0b10
    call scr_backspace
.endif

    stack_free 4
    ret

