# RISC-V OS Architecture

## System Overview

RISC-V OS is a minimalistic operating system implemented primarily in assembly language, designed to run on 32-bit RISC-V processors. The system is conceptually similar to the C64's Kernal, providing basic system services while maintaining a small footprint.

## Key Components

### 1. Core System

- **Execution Modes**
  - Machine Mode (M-Mode): Highest privilege level, handles critical system functions
  - User Mode (U-Mode): Used for running shell and user applications
  
- **Memory Layout**
  - Total RAM: 4MB
  - Text Section: Contains executable code
  - Data Section: Static data and system variables
  - Stack: User and system stacks
  - Device Memory: Memory-mapped I/O regions

### 2. Interrupt Handling

The system implements a comprehensive interrupt handling system in `irq.s`:

- **Exception Types**
  - Instruction address misaligned
  - Instruction access fault
  - Illegal instruction
  - Breakpoint
  - External interrupts
  - System calls

- **Interrupt Processing**
  - Context saving/restoration
  - Vectored interrupt handling
  - Priority-based interrupt management (via PLIC)

### 3. Hardware Abstraction Layer (HAL)

The HAL provides a uniform interface to hardware components:

- **UART Driver**
  - Character I/O
  - Interrupt-driven input
  - Configurable baud rate

- **RTC Driver**
  - Real-time clock access
  - Time/date functions

- **PLIC (Platform-Level Interrupt Controller)**
  - Interrupt priority management
  - Device interrupt routing
  - Platform-specific configurations

### 4. File System

A basic read-only file system implementation:

- TAR-based file system structure
- Basic file operations (read, seek)
- Directory listing support

### 5. Shell Interface

Interactive command shell providing:

- Command parsing and execution
- Built-in system commands
- Error reporting
- User input handling

## Hardware Support

Currently supported platforms:
1. QEMU virt machine
2. SiFive U-series
3. SiFive E-series

Each platform has specific configurations for:
- Memory layout
- Interrupt routing
- Device mappings
- Platform initialization

## RISC-V Extensions

The system utilizes minimal RISC-V extensions:
- E (Embedded): Base integer instruction set
- M (Multiplication/Division): Integer multiplication/division operations
- Zicsr: Control and Status Register access

## System Call Interface

System calls are implemented through the `ecall` instruction, providing:
- Process control
- I/O operations
- System information
- Device management

## Future Architecture Considerations

Areas planned for architectural enhancement:
1. Supervisor mode implementation
2. Virtual memory support
3. Process scheduling
4. Enhanced security features
5. Dynamic memory management
