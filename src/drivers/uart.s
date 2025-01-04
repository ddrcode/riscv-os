# UART "driver" for RISC-V OS
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "config.s"
    .include "macros.s"

.global print_screen
.global putc
.global puts

.section .text

# a0 - String address
.type puts, @function
puts:
    beqz a0, 2f
    li a1, UART_BASE
1:                                     # While string byte is not null
    lb t0, (a0)                        # Get byte at current string pos
    beq zero, t0, 3f                   # Is null?
    sb t0, (a1)                        # No, write byte to port
    inc a0                             # Inc string pos
    j 1b                               # Loop
2:                                     # String byte is null
    li a0, 2                           # Set error code
    j 4f
3:  setz a0                            # Set exit code
4:  ret

# prints a single character to the screen
# a0 - char code
.type putc, @function
putc:
    li t0, UART_BASE
    sb a0, (t0)
    ret


# Prints the content of screen memory to uart
.type print_screen, @function
print_screen:
    stack_alloc 4
    call _print_frame
    la a0, screen                      # set a0 to beginning of screen region
    li a1, UART_BASE
    li t1, SCREEN_WIDTH                # t1 is a  char counter within line
    li t2, SCREEN_HEIGHT               # t2 is a line counter
    li a4, 32                          # space character
    li t0, '|'
    sb t0, (a1)
1:
    lb t0, (a0)                        # load a single byte to t0
    bge t0, a4, 2f                     # if it's printable character jump to 2
    mv t0, a4                          # otherwise replace character with space
2:
    sb t0, (a1)                        # send byte to uart
    dec t1                             # decrement t1
    inc a0                             # increment a1
    beqz t1, 3f
    j 1b                               # jump to 1
3:
    li t0, '|'
    sb t0, (a1)
    li t0, '\n'                        # EOL character
    sb t0, (a1)                        # send to UART
    li t1, SCREEN_WIDTH                # reset t1 to 40
    dec t2                             # decrement t2
    beqz t2, 4f                        # if t2 is zero jump to 3:
    li t0, '|'
    sb t0, (a1)
    j 1b
4:
    setz a0
    setz a1
    call set_cursor_pos
    call _print_frame
    stack_free 4
    ret


_print_frame:
    li t0, '-'
    li t1, 42
    la t2, UART_BASE
1:
    beqz t1, 2f
        sb t0, (t2)
        dec t1
        j 1b
2:
    li t0, '\n'
    sb t0, (t2)
    ret

