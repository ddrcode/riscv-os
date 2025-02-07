# Hardware Support

This document details the hardware platforms and requirements for running RISC-V OS.

## Supported Platforms

### 1. QEMU virt Machine
- **Description**: Generic RISC-V virtual platform
- **Memory**: 4MB RAM
- **Devices**:
  - 16550A UART
  - Goldfish RTC
  - PLIC
  - Virtual framebuffer
- **Configuration**: Default platform

### 2. SiFive U-Series
- **Description**: Application processor platform
- **Memory**: 4MB RAM
- **Devices**:
  - SiFive UART
  - RTC
  - PLIC
  - Platform-specific peripherals
- **Configuration**: Requires specific platform setup

### 3. SiFive E-Series
- **Description**: Embedded processor platform
- **Memory**: 4MB RAM
- **Devices**:
  - SiFive UART
  - RTC
  - PLIC
  - Limited peripheral set
- **Configuration**: Minimal platform setup

## Hardware Requirements

### Processor
- **Architecture**: RISC-V (32-bit)
- **Required Extensions**:
  - E (Embedded): Base integer instruction set
  - M (Multiplication/Division)
  - Zicsr (Control and Status Register)
- **Optional Extensions**:
  - C (Compressed Instructions)
  - F (Single-precision Floating-point)

### Memory
- **Minimum**: 4MB RAM
- **Recommended**: 8MB+ RAM
- **Layout**:
  - Text section
  - Data section
  - Stack
  - Device memory

### Peripherals
- **Required**:
  - UART (16550A compatible)
  - RTC
  - PLIC or basic interrupt controller
- **Optional**:
  - Framebuffer
  - Additional serial ports
  - Custom devices

## Device Support

### UART
- **Supported Controllers**:
  - 16550A
  - SiFive UART
- **Features**:
  - Configurable baud rate
  - Interrupt support
  - FIFO buffers
- **Configuration**:
  - Memory-mapped I/O
  - Platform-specific base address

### RTC
- **Supported Controllers**:
  - Goldfish RTC
  - SiFive RTC
- **Features**:
  - Time/date functions
  - Alarm capability
  - Interrupt support
- **Configuration**:
  - Memory-mapped registers
  - Platform-specific setup

### PLIC
- **Features**:
  - Priority-based interrupts
  - Multiple interrupt sources
  - Configurable priorities
- **Configuration**:
  - Platform-specific interrupt mapping
  - Priority configuration
  - Enable/disable control

### Framebuffer
- **Features**:
  - Text mode (40x25 characters)
  - Basic graphics support
  - Memory-mapped display
- **Configuration**:
  - Resolution settings
  - Memory mapping
  - Character set

## Adding New Hardware Support

### Platform Integration
1. Create platform file in `src/platforms/`
2. Define memory map
3. Configure interrupt routing
4. Set up device initialization
5. Implement platform-specific functions

### Device Driver Development
1. Create driver in `src/drivers/`
2. Implement HAL interface
3. Add device configuration
4. Test on target platform
5. Update documentation

### Hardware Abstraction Layer
1. Define interface in HAL
2. Implement platform-specific functions
3. Add device management
4. Update build system
5. Add tests

## Platform-Specific Notes

### QEMU virt
- Default development platform
- Generic RISC-V implementation
- Full device support
- Easiest to set up and test

### SiFive U-Series
- Application processor focus
- Additional peripherals
- Performance features
- Complex interrupt handling

### SiFive E-Series
- Embedded system focus
- Limited peripheral set
- Simplified interrupt handling
- Resource constraints

## Future Hardware Support

### Planned Platforms
1. Newer SiFive boards
2. Additional QEMU machines
3. Custom FPGA implementations

### Hardware Features
1. More RISC-V extensions
2. Additional peripherals
3. Enhanced graphics support
4. Network interfaces

## Troubleshooting

### Common Issues
1. Memory conflicts
2. Interrupt routing problems
3. Device initialization failures
4. Timing issues

### Debug Tools
1. QEMU debugging
2. Hardware probes
3. Logic analyzers
4. System monitors

## References

- [RISC-V Specifications](https://riscv.org/specifications/)
- [QEMU Documentation](https://www.qemu.org/docs/master/)
- [SiFive Hardware Manual](https://sifive.cdn.prismic.io/sifive/d3ed5cd0-6e74-46b2-a12d-72b06706513e_sifive-e31-manual-v19.08.pdf)
- [16550A UART Specification](https://www.ti.com/lit/ds/symlink/pc16550d.pdf)
