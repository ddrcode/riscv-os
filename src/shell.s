# Simple shell with a few standard commands
# for RISC-V OS
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "macros.s"
.include "consts.s"
.include "config.s"

.section .text

.global shell_init
.global shell_command_loop
.global exec_cmd
.global set_prompt
.global show_error
.global show_date_time

.type shell_init, @function
shell_init:
    stack_alloc
    call clear_screen
    la a0, welcome
    call println
    la a0, prompt
    call prints
    call show_cursor
    stack_free
    ret

.type shell_command_loop, @function
shell_command_loop:
    stack_alloc 64
1:
        mv a0, sp
        call read_line
        beqz a0, 1b
            li a0, '\n'
            call printc
            mv a0, sp
            call exec_cmd
        j 1b
    call panic                         # the loop should never end
    stack_free 64
    ret

# Arguments
#    a0 - cmd string pointer
exec_cmd:
    stack_alloc
    push a0, 8
    push zero, 4

    call split_cmd                     # split command from its args
    mv t0, a0
    pop a0, 8
    bltz t0, 1f                        # jump if there are no args
        add t0, t0, a0                 # compute args address...
        push t0, 4                     # and place it on the stack
1:
    call parse_cmd

    mv a5, a0                          # set the function id
    pop a0, 4                          # restore args addr from the stack
    ecall                              # call the system function

    la a0, prompt
    call prints

    stack_free
    ret


# Splits string between command and argument(s).
# It inserts '\0' after the command (instead of space)
# Arguments
#    a0 - cmd string pointer
# Returns
#    a0 - address of arguments string (or 0 if none)
split_cmd:
    stack_alloc
    push a0, 8

    li a1, ' '
    call str_find_char                 # search for space in cmd line
    bltz a0, 1f                        # exit if there is none (no args)
        pop t1, 8
        add t1, t1, a0                 # compute args addr
        sb zero, (t1)                  # replace space with '\0'
        inc a0                         # increment args addr
1:
    stack_free
    ret

# Parses command line
# Arguments:
#     a0 - pointer to command line string
# Returns:
#     a0 - system function id (or 0 when not found)
# TODO make index byte not word
parse_cmd:
    stack_alloc

    la a1, commands
    li a2, SYS_FN_LEN

    push a0, 8
    push a2, 0
1:                                   # do
        push a1, 4
        call strcmp
        bgtz a0, 2f                  # finish when command matches
            pop a2, 0                # retrieve index from the stack
            dec a2                   # decrement index
            beqz a2, 3f              # finnish if index is 0
            push a2, 0

            pop a1, 4                # retrieve array pointer from the stack
            mv a0, a1
            call strlen
            pop a1, 4
            add a1, a1, a0           # Move array pointer to the next item
            inc a1
            pop a0, 8                # retrieve command pointer from the stack
    j 1b
2:                                   # cmd found
    li t0, SYS_FN_LEN                # retrieve num of commands
    sub a0, t0, a2                   # fn_no = (no_of_comands - index) + 1
    inc a0
    j 4f
3:                                   # cmd not found
    setz a0
4:                                   # end
    stack_free
    ret


# Shows error
# Arguments:
#     a0 - error code
show_error:
    stack_alloc 4
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
    stack_free 4
    ret

.align 4
show_date_time:
    stack_alloc 32
.ifdef RTC_BASE
    call rtc_time_in_sec
    mv a1, sp
    call date_time_to_str
    mv a0, sp
.else
    la a0, err_no_rtc
.endif
    call println

    setz a5
    stack_free 32
    ret

# Set single-character prompt
# arguments:
#    a0 - pointer to prompt string (only the first char will be taken)
set_prompt:
    beqz a0, 1f
    la t0, prompt
    lbu t1, (a0)
    sb t1, (t0)
    sb zero, 2(t0)                     # make sure string terminates
    setz a5
    j 2f
1:
    li a5, 2                           # set error code
2:  ret


.section .data

prompt: .string "> "


.section .rodata

welcome: .string "Welcome to RISC-V OS v0.1"
# commands: .string "cls", "date", "prompt", "print", "fbdump"
commands: .string "cls"
          .string "date"
          .string "prompt"
          .string "print"
          .string "fbdump"

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

.ifndef RTC_BASE
err_no_rtc: .string "No RTC on this platform"
.endif
