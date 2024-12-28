# Simple shell with a few standard commands
# for RISC-V OS
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.section .text

.equ NUM_OF_ERRORS, 6                  # number of error codes

.global shell_init
.global exec_cmd
.global set_prompt

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


# Arguments
#    a0 - cmd string pointer
exec_cmd:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw a0, 8(sp)
    sw zero, 4(sp)

    call split_cmd                     # split command from its args
    mv t0, a0
    lw a0, 8(sp)
    bltz t0, 1f                        # jump if there are no args
        add t0, t0, a0                 # compute args address...
        sw t0, 4(sp)                   # and place it on the stack
1:
    call parse_cmd

    lw a1, 4(sp)                       # restore args addr from the stack
    call syscall

    la a0, prompt
    call print_str

    lw ra, 12(sp)
    addi sp, sp, 16
    ret


# Splits string between command and argument(s).
# It inserts '\0' after the command (instead of space)
# Arguments
#    a0 - cmd string pointer
# Returns
#    a0 - address of arguments string (or 0 if none)
split_cmd:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw a0, 8(sp)

    li a1, ' '
    call str_find_char                 # search for space in cmd line
    bltz a0, 1f                        # exit if there is none (no args)
        lw t1, 8(sp)
        add t1, t1, a0                 # compute args addr
        sb zero, (t1)                  # replace space with '\0'
        inc a0                         # increment args addr
1:
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

# Parses command line
# Arguments:
#     a0 - pointer to command line string
# Returns:
#     a0 - system function id (or 0 when not found)
# TODO make index byte not word
parse_cmd:
    la a1, commands
    li a2, SYS_FN_LEN

    addi sp, sp, -16
    sw ra, 12(sp)
    sw a0, 8(sp)
    sw a2, (sp)
1:                                   # do
        sw a1, 4(sp)
        call strcmp
        bgtz a0, 2f                  # finish when command matches
            lw a2, (sp)              # retrieve index from the stack
            dec a2                   # decrement index
            beqz a2, 3f              # finnish if index is 0
            sw a2, (sp)

            lw a1, 4(sp)             # retrieve array pointer from the stack
            mv a0, a1
            call strlen
            lw a1, 4(sp)
            add a1, a1, a0           # Move array pointer to the next item
            inc a1
            lw a0, 8(sp)             # retrieve command pointer from the stack
    j 1b
2:                                   # cmd found
    li t0, SYS_FN_LEN                # retrieve num of commands
    sub a0, t0, a2                   # fn_no = (no_of_comands - index) + 1
    inc a0
    j 4f
3:                                   # cmd not found
    setz a0
4:                                   # end
    lw ra, 12(sp)
    addi sp, sp, 16
    ret


# Shows error
# Arguments:
#     a0 - error code
show_error:
    push ra
    li t0, NUM_OF_ERRORS
    blt a0, t0, 1f                     # jump if valid error code
        setz a0                        # otherwise set to unknown error
1:
    la t0, errors                      # compute error msg address...
    li t1, 4
    mul t1, t1, a0
    add t0, t0,t1
    lw a0, (t0)
    call println
    setz a5
    pop ra
    ret

show_date_time:
    push ra
    la a0, date
    call println
    setz a5
    pop ra
    ret

# Set single-character prompt
# arguments:
#    a0 - pointer to prompt string (only the first char will be taken)
set_prompt:
    beqz a0, 1f
    la t0, prompt
    lb t1, (a0)
    sb t1, (t0)
    setz a5
    j 2f
1:
    li a5, 2                           # set error code
2:  ret


.section .data

prompt: .string "> "


.section .rodata

welcome: .string "Welcome to RISC-V OS v0.1"
commands: .string "cls", "date", "prompt", "print"
date: .string "2024-12-20 21:17:32 (fake date)"

err_unknown: .string "Unknown error"
err_not_found: .string "Command not found"
err_missing_arg: .string "Missing argument"
err_not_supported: .string "Not supported"
err_invalid_argument: .string "Invalid argument"
err_stack_overflow: .string "Stack overflow"

errors: .word err_unknown
        .word err_not_found
        .word err_missing_arg
        .word err_not_supported
        .word err_invalid_argument
        .word err_stack_overflow

