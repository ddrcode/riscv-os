.section .text

.global shell_init

shell_init:
    push ra
    call clear_screen
    la a0, welcome
    call println
    la a0, prompt
    call print_str
    call show_cursor
    pop ra
    ret

# Parses command line
# Arguments:
#     a0 - pointer to command line string
# Returns:
#     a0 - system function id (or 0 when not found)
# TODO make index byte not word
parse:
    la a0, prompt
    la a1, commands
    la a2, cmd_len
    lb a2, (a2)

    addi sp, sp, -16
    sw ra, 12(sp)
    sw a0, 8(sp)
1:                                   # do
        sw a1, 4(sp)
        sw a2, (sp)

        call strcmp
        lw a2, (sp)                  # retrieve index from the stack
        bgtz a0, 2f                  # finish when command matches
        dec a2                       # decrement index
        beqz a2, 3f                  # finnish if index is 0
        lw a1, 4(sp)                 # retrieve array pointer for the stack
        inc a1                       # and increment it
        lw a0, 8(sp)                 # retrieve command pointer from the stack
    j 1b
2:                                   # cmd found
    la t0, cmd_len                   # retrieve num of commands
    lb t0, (t0)
    sub a0, t0, a2                   # fn_no = (no_of_comands-index) + 1
    inc a0
    j 4f
3:                                   # cmd not found
    setz a0
4:                                   # end
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

.section .data

cmd_len: .byte 4
prompt: .string "> "
commands: .string "cls", "date", "prompt", "print"
welcome: .string "Welcome to RISC-V OS v0.1"

