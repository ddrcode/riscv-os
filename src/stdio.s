.include "macros.s"

.global putc
.global puts
.global getc

.section .text

.type putc, @function
putc:
    stack_alloc 4
    call uart_putc
    stack_free 4
    ret

.type puts, @function
puts:
    stack_alloc 4
    call uart_puts
    stack_free 4
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
        beq a0, t0, 2f
        li t0, 13
        beq a0, t0, 2f
        li t0, 32
        blt a0, t0, 1b                 # ignore special characters
            sb a0, (s1)                # store character
            inc s1                     # increase the pointer
            call putc                  # print character
            j 1b
2:
    sb zero, s1                        # close the string
    pop a0, 4
    sub a0, s1, a0                     # compute string length
    pop s1, 8
    stack_free
    ret

