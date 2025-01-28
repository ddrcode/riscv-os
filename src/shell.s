# Simple shell with a few standard commands
# for RISC-V OS
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE file for license details.

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

fn shell_init
    stack_alloc

.if OUTPUT_DEV & 0b101
    call scr_init
    call clear_screen
.endif

    la a0, welcome
    call println
    la a0, prompt
    call prints

.if OUTPUT_DEV & 1
    call show_cursor
.endif

    call shell_command_loop
    stack_free
    ret
endfn


fn shell_command_loop
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
endfn


# Arguments
#    a0 - cmd string pointer
fn exec_cmd
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
    beqz a0, 2f                        # show error if command not found

    li t0, 512                         # FIXME So ugly!
    blt a0, t0, 11f                    # If returned file id (large number), run program

        pop a1, 8                      # program name (argv[0])
        pop a2, 4                      # args address (argv[1])
        call run_prog
        j 2f

11:
    addr_from_vec shell_cmd_vector, a0, t0

    pop a0, 4                          # restore args addr from the stack
    jalr t0                            # call the system function

2:
    beqz a5, 3f                        # check for errors
        mv a0, a5
        call show_error

3:
    la a0, prompt
    call prints

    stack_free
    ret
endfn


# Splits string between command and argument(s).
# It inserts '\0' after the command (instead of space)
# Arguments
#    a0 - cmd string pointer
# Returns
#    a0 - address of arguments string (or 0 if none)
fn split_cmd
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
endfn


# Parses command line
# Arguments:
#     a0 - pointer to command line string
# Returns:
#     a0 - system function id (or 0 when not found)
#     a5 - error code
# TODO make index byte not word
fn parse_cmd
    stack_alloc
    push s1, 0

    la a1, commands
    mv s1, zero

    push a0, 8
1:                                   # do
        push a1, 4
        call strcmp
        bgtz a0, 2f                  # finish when command matches
            inc s1                   # increment index

            pop a1, 4                # retrieve array pointer from the stack
            mv a0, a1
            call strlen
            pop a1, 4
            add a1, a1, a0           # Move array pointer to the next item
            inc a1
            lbu t2, (a1)
            beqz t2, 3f              # finish if the next item is 0
            pop a0, 8                # retrieve command pointer from the stack
    j 1b
2:                                   # cmd found
    addi a0, s1, 1
    setz a5                          # insert 0 in place of space between cmd and argument
    j 5f
3:                                   # cmd not found (look for file)
    pop a0, 8
    call file_find
    bnez a0, 5f
4:                                   # command & file not found
    setz a0
    li a5, ERR_CMD_NOT_FOUND
5:                                   # end
    pop s1, 0
    stack_free
    ret
endfn


# Shows error
# Arguments:
#     a0 - error code
fn show_error
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
endfn


# Set single-character prompt
# arguments:
#    a0 - pointer to prompt string (only the first char will be taken)
fn set_prompt
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
endfn


# Runs program from disc
# Arguments:
#     a0 - file id
#     a1 - program name
#     a2 - args address
fn run_prog
    stack_alloc 16
    snez t0, a2                        # has the program been called with args?
    inc t0                             # arg count is always at least 1 (argv[0] is program name)

    pushb t0, 0                        # argc
    push a1, 1                         # argv[0] - program name
    push a2, 5                         # argv[1] - arguments (TODO split them)

    syscall SYSFN_RUN
    stack_free 16
    ret
endfn

#----------------------------------------

.section .data

prompt: .string "> "


#----------------------------------------

.section .rodata

welcome: .string "Welcome to RISC-V OS v0.1"

commands: .string "cls"
          .string "prompt"
          .string "print"

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

shell_cmd_vector:
        .word show_error
        .word clear_screen
        .word set_prompt
        .word println
        .word 0
