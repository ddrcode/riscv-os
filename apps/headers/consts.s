.ifndef __CONSTS_S__
.equ __CONSTS_S__, 1

# System functions

.equ SYSFN_SLEEP, 1
.equ SYSFN_IDLE, 2
.equ SYSFN_RUN, 3
.equ SYSFN_EXIT, 4
.equ SYSFN_GET_CFG, 5

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

# Frambuffer function
.equ SYSFN_FB_INFO, 40
.equ SYSFN_FB_GET_CURSOR, 41
.equ SYSFN_FB_SET_CURSOR, 42

.equ SYSFN_LAST_FN_ID, 43

# Error Codes

.equ NUM_OF_ERRORS, 6                  # number of error codes

.equ ERR_UNKNOWN, 0
.equ ERR_CMD_NOT_FOUND, 1
.equ ERR_MISSING_ARGUMENT, 2
.equ ERR_NOT_SUPPORTED, 3
.equ ERR_INVALID_ARGUMENT, 4
.equ ERR_STACK_OVERFLOW, 5


# SYSTEM CONFIG

.equ INFO_OUTPUT_DEV, 0
.equ CFG_STD_OUT, 4
.equ CFG_STD_IN, 8
.equ CFG_STD_ERR, 12
.equ CFG_STD_DEBUG, 16
.equ CFG_PLATFORM_NAME, 20


# HAL

.equ DRV_UART_STRUCT_SIZE, 16
.equ DRV_RTC_STRUCT_SIZE, 8

# DEVICE MANAGER

.equ DEV_MAX_DEVICES_NO, 16

.equ DEV_UART_0, 0
.equ DEV_UART_1, 4
.equ DEV_UART_2, 8
.equ DEV_UART_3, 12

.equ DEV_RTC_0, 16
.equ DEV_RTC_1, 20



.endif
