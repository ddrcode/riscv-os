# Hardware Support

This document details the hardware platforms and requirements for running RISC-V OS.

## Supported Platforms

### 1. QEMU Virt Machine
- **Description**: Generic RISC-V virtual platform
- **Memory**: 4MB RAM
- **Supported Devices**:
  - 16550A UART
  - Goldfish RTC
  - PLIC
  - Flash drive (Read-only)
- **Configuration**: Default platform

### 2. QEMU SiFive U-Series
- **Description**: Application processor platform
- **Memory**: 4MB RAM
- **Supported Devices**:
  - SiFive UART (2x)
  - PLIC
  - Flash-drive (read-only)
- **Configuration**: Requires specific platform setup

### 3. QEMU SiFive E-Series
- **Description**: Embedded processor platform
- **Memory**: 4MB RAM
- **Supported Devices**:
  - SiFive UART (2x)
  - PLIC
- **Configuration**: Minimal platform setup

## Hardware Requirements

### Processor
- **Architecture**: RISC-V (32-bit)
- **Required Extensions**:
  - E (Embedded): Base integer instruction set
  - M (Multiplication/Division) - optional (fallback provided on OS level)
  - Zicsr (Control and Status Register)

## Device Support

### UART
- **Supported Controllers**:
  - 16550A
  - SiFive UART

### RTC
- **Supported Controllers**:
  - Goldfish RTC

### PLIC

### Framebuffer
- **Features**:
  - Text mode (40x25 characters)
  - Basic graphics support
  - Memory-mapped display
  
### Storage
- RAM disc with read-only TarFS Filesystem


## Future Hardware Support

### Planned Platforms
1. Sipeed Longan Nano 

### Hardware Features
1. Block devices (SD card reader)

## References

- [RISC-V Specifications](https://riscv.org/specifications/)
- [QEMU Documentation](https://www.qemu.org/docs/master/)
- [SiFive Hardware Manual](https://sifive.cdn.prismic.io/sifive/d3ed5cd0-6e74-46b2-a12d-72b06706513e_sifive-e31-manual-v19.08.pdf)
- [16550A UART Specification](https://www.ti.com/lit/ds/symlink/pc16550d.pdf)
