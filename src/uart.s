.equ UART_BASE, 0x10000000


puts:
  # a0 - String address
  # a1 - UART base address
1:                    # While string byte is not null
  lb t0, 0(a0)        # Get byte at current string pos
  beq zero, t0, 2f    # Is null?
  sb t0, (a1)         # No, write byte to port
  inc a0              # Inc string pos
  j 1b                # Loop
2:                    # String byte is null
  ret


# prints a single character to the screen
# a0 - screen address of a character
# a1 - char code
putc:
    li t0, UART_BASE
    sb a1, (t0)
    ret


# Prints the content of screen memory to uart
print_screen:
    la a0, screen                   # set a0 to beginning of screen region
    li a1, UART_BASE
    li t1, 40                       # t1 is a  char counter within line
    li t2, 25                       # t2 is a line counter
1:
    lb t0, 0(a0)                    # load a singl byte to t0
    sb t0, (a1)                     # send byte to uart
    dec t1                          # decrement t1
    inc a0                          # increment a1
    beqz t1, 2f
    j 1b                            # jump to 1
2:
    li t0, '\n'                     # EOL character
    sb t0, (a1)                     # send to UART
    li t1, 40                       # reset t1 to 40
    dec t2                          # decrement t2
    beqz t2, 3f                     # if t2 is zero jump to 3:
    j 1b
3:
    push ra
    setz a0
    setz a1
    call set_cursor_pos
    pop ra
    ret

