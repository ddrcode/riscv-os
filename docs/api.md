# API Reference

This document provides detailed information about the system's API, including system calls, driver interfaces, and error codes.

## System Calls

System calls are invoked using the `ecall` instruction. All system calls follow this convention:
- `a0`: System call number
- `a1-a3`: Parameters
- `a0`: Return value
- `a5`: Error code (0 = success)

### Process Management

#### `sys_exit`
Terminate current process
- **Number**: 1
- **Parameters**: None
- **Returns**: Never returns
- **Errors**: None

#### `sys_sleep`
Sleep for specified milliseconds
- **Number**: 2
- **Parameters**:
  - `a1`: Milliseconds to sleep
- **Returns**: None
- **Errors**:
  - `EINVAL`: Invalid time value

### I/O Operations

#### `sys_putchar`
Output single character
- **Number**: 3
- **Parameters**:
  - `a1`: Character to output
- **Returns**: None
- **Errors**:
  - `EIO`: I/O error

#### `sys_getchar`
Get input character
- **Number**: 4
- **Parameters**: None
- **Returns**: Character read
- **Errors**:
  - `EIO`: I/O error
  - `EINTR`: Interrupted operation

### File Operations

#### `sys_open`
Open a file
- **Number**: 5
- **Parameters**:
  - `a1`: Pointer to filename
  - `a2`: Mode flags
- **Returns**: File descriptor
- **Errors**:
  - `ENOENT`: File not found
  - `EINVAL`: Invalid mode

#### `sys_read`
Read from file
- **Number**: 6
- **Parameters**:
  - `a1`: File descriptor
  - `a2`: Buffer pointer
  - `a3`: Count
- **Returns**: Bytes read
- **Errors**:
  - `EBADF`: Bad file descriptor
  - `EIO`: I/O error

## Driver Interfaces

### UART Driver

#### `uart_init`
Initialize UART device
- **Parameters**:
  - `a0`: Base address
  - `a1`: Baud rate
- **Returns**: 0 on success
- **Errors**:
  - `EINVAL`: Invalid parameters
  - `EIO`: Hardware error

#### `uart_putc`
Send character
- **Parameters**:
  - `a0`: Character
- **Returns**: None
- **Errors**:
  - `EIO`: Hardware error

### RTC Driver

#### `rtc_get_time`
Get current time
- **Parameters**: None
- **Returns**:
  - `a0`: Seconds since epoch
- **Errors**:
  - `EIO`: Hardware error

#### `rtc_set_time`
Set current time
- **Parameters**:
  - `a0`: Seconds since epoch
- **Returns**: 0 on success
- **Errors**:
  - `EINVAL`: Invalid time
  - `EIO`: Hardware error

### Video Terminal

#### `vt_init`
Initialize video terminal
- **Parameters**:
  - `a0`: Width
  - `a1`: Height
- **Returns**: 0 on success
- **Errors**:
  - `EINVAL`: Invalid dimensions
  - `EIO`: Hardware error

#### `vt_clear`
Clear screen
- **Parameters**: None
- **Returns**: None
- **Errors**:
  - `EIO`: Hardware error

## Error Codes

| Code  | Name    | Description |
|-------|---------|-------------|
| 0     | EOK     | Success |
| 1     | EPERM   | Operation not permitted |
| 2     | ENOENT  | No such file or directory |
| 3     | EIO     | I/O error |
| 4     | EINTR   | Interrupted system call |
| 5     | EINVAL  | Invalid argument |
| 6     | EBADF   | Bad file descriptor |
| 7     | ENOMEM  | Out of memory |
| 8     | EBUSY   | Device or resource busy |
| 9     | EEXIST  | File exists |
| 10    | ENODEV  | No such device |

## Shell Commands

### Built-in Commands

#### `cls`
Clear screen
- **Usage**: `cls`
- **Parameters**: None
- **Returns**: None

#### `prompt`
Set shell prompt
- **Usage**: `prompt <char>`
- **Parameters**:
  - char: New prompt character
- **Returns**: None

#### `platform`
Show platform info
- **Usage**: `platform`
- **Parameters**: None
- **Returns**: Platform information string

#### `run`
Execute program
- **Usage**: `run <filename>`
- **Parameters**:
  - filename: Program to execute
- **Returns**: Program exit code

## HAL Interface

### Device Management

#### `dev_register`
Register device driver
- **Parameters**:
  - `a0`: Device ID
  - `a1`: Driver structure pointer
- **Returns**: 0 on success
- **Errors**:
  - `EINVAL`: Invalid parameters
  - `EEXIST`: Device already registered

#### `dev_unregister`
Unregister device driver
- **Parameters**:
  - `a0`: Device ID
- **Returns**: 0 on success
- **Errors**:
  - `ENODEV`: No such device

### Interrupt Management

#### `irq_enable`
Enable interrupt
- **Parameters**:
  - `a0`: IRQ number
- **Returns**: Previous state
- **Errors**: None

#### `irq_disable`
Disable interrupt
- **Parameters**:
  - `a0`: IRQ number
- **Returns**: Previous state
- **Errors**: None

## Best Practices

1. **Error Handling**
   - Always check return values
   - Handle all possible error codes
   - Use appropriate error recovery

2. **Resource Management**
   - Clean up resources in error paths
   - Use proper initialization/cleanup pairs
   - Check resource limits

3. **Interrupt Safety**
   - Use appropriate synchronization
   - Minimize time in interrupt context
   - Handle nested interrupts properly

4. **Documentation**
   - Document all parameters
   - Specify error conditions
   - Provide usage examples
