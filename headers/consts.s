.ifndef __CONSTS_S__
.equ __CONSTS_S__, 1

# System functions

.equ SYS_FN_LEN, 5


.equ SYSFN_IDLE, 2

# Time functions
.equ SYSFN_GET_SECS_FROM_EPOCH, 10
.equ SYSFN_GET_DATE, 11
.equ SYSFN_GET_TIME, 13

# I/O functions
.equ SYSFN_GET_CHAR, 20
.equ SYSFN_PRINT_CHAR, 21
.equ SYSFN_PRINT_STR, 22

.equ SYSFN_LAST_FN_ID, 23

# Error Codes

.equ NUM_OF_ERRORS, 6                  # number of error codes

.equ ERR_UNKNOWN, 0
.equ ERR_CMD_NOT_FOUND, 1
.equ ERR_MISSING_ARGUMENT, 2
.equ ERR_NOT_SUPPORTED, 3
.equ ERR_INVALID_ARGUMENT, 4
.equ ERR_STACK_OVERFLOW, 5

.endif
