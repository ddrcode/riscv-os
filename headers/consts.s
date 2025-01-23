.ifndef __CONSTS_S__
.equ __CONSTS_S__, 1

# System functions

.equ SYSFN_SLEEP, 1
.equ SYSFN_IDLE, 2
.equ SYSFN_RUN, 3
.equ SYSFN_EXIT, 4

# Time functions
.equ SYSFN_GET_SECS_FROM_EPOCH, 10
.equ SYSFN_GET_DATE, 11
.equ SYSFN_GET_TIME, 13

# I/O functions
.equ SYSFN_GET_CHAR, 20
.equ SYSFN_PRINT_CHAR, 21
.equ SYSFN_PRINT_STR, 22

# File functions
.equ SYSFN_FILE_INFO, 30
.equ SYSFN_READ, 31

.equ SYSFN_LAST_FN_ID, 32

# Error Codes

.equ NUM_OF_ERRORS, 6                  # number of error codes

.equ ERR_UNKNOWN, 0
.equ ERR_CMD_NOT_FOUND, 1
.equ ERR_MISSING_ARGUMENT, 2
.equ ERR_NOT_SUPPORTED, 3
.equ ERR_INVALID_ARGUMENT, 4
.equ ERR_STACK_OVERFLOW, 5

.endif
