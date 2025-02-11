# Development Guide

This guide provides information for developers who want to understand, modify, or extend the RISC-V OS.

## Project Structure

```
riscv-os/
├── apps/           # External applications
├── build/          # Build artifacts
├── headers/        # Header files
│   ├── drivers/    # Device driver headers
│   ├── hal/        # Hardware abstraction headers
│   ├── platforms/  # Platform-specific headers
│   ├── sys/        # System-specific headers
│   ├── config.s    # Configuration macros
│   ├── consts.s    # Common constants
│   ├── macros.s    # Common macros
│   ├── math32.h    # 32-bit math operations
│   ├── math64.h    # 64-bit math operations
│   ├── string.h    # String operations
│   └── types.h     # Common type definitions
├── lib/            # Shared library functions
│   ├── math32.s    # 32-bit math operations
│   ├── math64.s    # 64-bit math operations
│   └── string.s    # String manipulation functions
├── platforms/      # Platform-specific linker and make files
├── src/            # Source code
│   ├── drivers/    # Device drivers
│   ├── hal/        # Hardware Abstraction Layer
│   └── platforms/  # Platform implementations
└── tests/          # Test files
```

### Key Files

- `src/main.s`: System entry point
- `src/irq.s`: Interrupt handling
- `src/shell.s`: Shell implementation
- `src/system.s`: Core system functions
- `src/sysfn.s`: System call implementations
- `headers/config.s`: System configuration
- `headers/consts.s`: Common constants
- `headers/macros.s`: Common macros
- `headers/types.h`: Common type definitions
- `lib/math32.s`: 32-bit math operations
- `lib/math64.s`: 64-bit math operations
- `lib/string.s`: String manipulation functions
- `lib/io.s`: Input/Output to UART and/or framebuffer

## Coding Standards

### Assembly Style Guide

1. **Naming Conventions**
   - Functions: lowercase with underscores (e.g., `handle_interrupt`)
   - Labels: descriptive names with colons
   - Constants: uppercase with underscores
   - Registers: use standard RISC-V register names

2. **Comments**
   - Begin files with header comment (author, license)
   - Document function parameters and return values
   - Explain complex algorithms

3. **Code Organization**
   - Group related functions together
   - Use sections appropriately (.text, .data, .rodata)
   - Keep functions focused and small
   - Use macros for repeated code patterns

### Example Function Template

```assembly
# Function Name: my_function
# Description: Brief description of what the function does
#
# Parameters:
#   a0 - first parameter description
#   a1 - second parameter description
#
# Returns:
#   a0 - return value description
#   a5 - error code (0 if successful)
#
# Modifies: list of registers modified
fn my_function
    # Function prologue
    stack_alloc
    push s1, 0
    
    # Function body
    ...
    
    # Function epilogue
    pop s1, 0
    stack_free
    ret
endfn
```

## Adding New Features

### Adding a New System Call

1. Define the system call number in `headers/consts.s`
2. Implement the handler in `src/sysfn.s`
3. Add error handling
4. Update documentation
5. Add tests

### Adding a New Driver

1. Create driver file in `src/drivers/`
2. Implement required HAL interface
3. Add platform-specific configuration
4. Update device manager
5. Add documentation and tests

### Adding Platform Support

1. Create platform file in `src/platforms/`
2. Define hardware configuration in `headers/platforms`
3. Implement platform initialization
4. Update build system in `platforms`
5. Add documentation

## Testing Guidelines

### Test Categories

1. **Unit Tests**
   - Individual function testing
   - Error condition verification
   - Edge case handling

2. **Integration Tests**
   - System call testing
   - Device driver testing
   - Platform testing

3. **System Tests**
   - Full system functionality
   - Performance testing
   - Stress testing

### Writing Tests

1. Create test file in `tests/` directory
2. Implement test setup and teardown
3. Define test cases
4. Add error checking
5. Document expected results

### Running Tests

```bash
# Run all tests
make test

# Run specific test
make test TEST_NAME=test_name

# Run with debugging
make debug TEST_NAME=test_name
```

## Debugging

### Using GDB

1. Start QEMU in debug mode:
   ```bash
   make debug TEST_NAME=test_name
   ```

2. Connect GDB:
   ```bash
   make gdb TEST_NAME=test_name
   ```

### Common Debug Commands

```gdb
# Set breakpoint
break function_name

# Examine memory
x/Nx address

# Show registers
info registers

# Step instruction
stepi

# Continue execution
continue
```

## Performance Optimization

### Guidelines

1. Profile code to identify bottlenecks
2. Optimize critical paths
3. Use appropriate RISC-V extensions
4. Minimize memory access
5. Consider cache behavior

### Tools

- Performance counters
- Execution profiling
- Memory analysis
- Instruction counting

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes following guidelines
4. Add tests
5. Update documentation
6. Submit pull request

## Resources

- [RISC-V Specifications](https://riscv.org/specifications/)
- [RISC-V Assembly Programming](https://riscv-programming.org/book/riscv-book.html)
- [Project Issues](https://github.com/ddrcode/riscv-os/issues)
- [Wiki](https://github.com/ddrcode/riscv-os/wiki)
