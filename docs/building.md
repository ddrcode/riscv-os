# Building and Running RISC-V OS

This guide provides detailed instructions for building and running the RISC-V OS.

## Prerequisites

### Required Tools
- [Nix](https://nixos.org/download.html) package manager (recommended)
- RISC-V GNU Toolchain
- QEMU with RISC-V support
- Git

### Optional Tools
- GDB for debugging
- direnv for automatic environment loading

## Building the System

### Using Nix (Recommended)

1. Enter the project directory:
   ```bash
   cd riscv-os
   ```

2. Start the Nix shell:
   ```bash
   nix-shell
   ```
   
   Or if using direnv:
   ```bash
   direnv allow
   ```

### Building Applications

1. Clone the applications repository:
   ```bash
   git clone https://github.com/ddrcode/riscv-os-apps apps
   ```

2. Build the applications disc:
   ```bash
   cd apps
   make disc
   cd ..
   ```

### Building the OS

1. Build the system:
   ```bash
   make
   ```

## Running the System

### Basic Execution

Run with default configuration (virt machine):
```bash
make run
```

Run with applications disc:
```bash
make run DRIVE=apps/disc.tar
```

### Platform Selection

Run on specific machine:
```bash
make run MACHINE=sifive_u
```

Available machines:
- `virt` (default)
- `sifive_e`
- `sifive_u`

### Output Options

Control system output with OUTPUT_DEV:
```bash
make run OUTPUT_DEV=5
```

Output options:
- `1`: Framebuffer only
- `2`: Serial console only
- `3`: Both framebuffer and console
- `5`: Terminal emulation mode

## Debugging

### Starting Debug Session

1. Start QEMU in debug mode:
   ```bash
   make debug TEST_NAME=shell
   ```

2. In another terminal, connect GDB:
   ```bash
   make gdb TEST_NAME=shell
   ```

### Running Tests

Execute specific test:
```bash
make test TEST_NAME=test_name
```

Available tests:
- `shell`
- `math32`
- `math64`
- `string`
- `rtc`

## Common Issues

### Build Failures
- Ensure all prerequisites are installed
- Check Nix environment is properly loaded
- Verify RISC-V toolchain is in PATH

### QEMU Issues
- Verify QEMU RISC-V support is installed
- Check machine type compatibility
- Verify memory settings

### Application Loading
- Ensure apps disc is properly built
- Verify disc.tar path is correct
- Check file permissions

## Performance Optimization

### Build Optimization
- Use appropriate optimization flags
- Consider platform-specific optimizations
- Enable relevant RISC-V extensions

### Debug vs Release
- Debug builds include additional information
- Release builds optimize for performance
- Use appropriate build for your needs
