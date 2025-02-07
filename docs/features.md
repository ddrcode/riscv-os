# System Features

This document details the features and capabilities of the RISC-V OS.

## Shell Interface

### Available Commands

The shell provides a command-line interface for interacting with the system. Here are the available commands:

| Command | Description |
|---------|-------------|
| `cls` | Clear the screen |
| `prompt` | Set shell prompt character |
| `platform` | Display current platform information |
| `fbdump` | Dump framebuffer content to serial output |
| `run` | Execute a program from the disc |

### Shell Features
- Command history
- Error reporting
- Configurable prompt
- Input line editing

## System Calls

System calls are implemented through the `ecall` instruction. Available system calls include:

### Process Management
- Process creation and termination
- Sleep and idle functions
- System information queries

### I/O Operations
- Character input/output
- Screen manipulation
- Device control

### Time Functions
- Real-time clock access
- Time/date retrieval
- Delay functions

## File System

The system implements a basic read-only file system with the following features:

### File Operations
- File opening and closing
- Sequential read operations
- Directory listing
- File seeking

### File System Structure
- TAR-based file organization
- Flat file hierarchy
- Basic metadata support

## Device Drivers

### UART Driver
- Character-based I/O
- Interrupt-driven input
- Configurable parameters
- Multiple UART support

### RTC Driver
- Real-time clock access
- Date and time functions
- Time zone handling

### Video Terminal
- Text-mode display (40x25 characters)
- Basic text attributes
- Cursor control
- Scrolling support

### PLIC (Platform-Level Interrupt Controller)
- Interrupt priority management
- Device interrupt routing
- Platform-specific configurations

## Memory Management

### Current Implementation
- Fixed 4MB RAM allocation
- Basic stack management
- Static memory allocation

### Memory Protection
- User/Machine mode separation
- Basic memory access control
- Stack overflow protection

## Hardware Abstraction Layer (HAL)

The HAL provides uniform access to hardware features across different platforms:

### Platform Support
- QEMU virt machine
- SiFive U-series
- SiFive E-series

### Hardware Features
- UART configuration
- Interrupt management
- Timer access
- Device mapping

## Security Features

### Access Control
- Mode-based execution (User/Machine)
- Memory protection
- System call validation

### Error Handling
- Exception handling
- Error reporting
- System recovery

## Development Features

### Debugging Support
- GDB integration
- Breakpoint handling
- System state inspection

### Testing
- Unit test framework
- Hardware simulation
- Performance testing

## Future Features

The following features are planned for future implementation:

1. **Enhanced Memory Management**
   - Virtual memory support
   - Dynamic memory allocation
   - Memory protection units

2. **Process Management**
   - Multi-process support
   - Process scheduling
   - IPC mechanisms

3. **File System Enhancements**
   - Write support
   - File permissions
   - Directory structure
   - File system caching

4. **Security Improvements**
   - Process isolation
   - Resource access controls
   - Input validation

5. **Hardware Support**
   - Additional RISC-V extensions
   - More hardware platforms
   - Additional peripheral support
