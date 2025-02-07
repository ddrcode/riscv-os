# Getting Started with RISC-V OS Development

Welcome to the RISC-V OS project! This guide will help you make your first contribution to the project.

## Prerequisites

Before you begin, ensure you have:
1. Basic understanding of assembly programming
2. Familiarity with RISC-V instruction set (or willingness to learn)
3. Development environment set up (see below)

## Setting Up Your Development Environment

### 1. Install Required Tools

The easiest way to get started is using Nix:

```bash
# Install Nix
curl -L https://nixos.org/nix/install | sh

# Optional but recommended: Install direnv
nix-env -i direnv
```

### 2. Clone the Repository

```bash
# Clone main repository
git clone https://github.com/ddrcode/riscv-os.git
cd riscv-os

# Clone applications repository
git clone https://github.com/ddrcode/riscv-os-apps apps
```

### 3. Set Up Development Environment

```bash
# Using Nix shell
nix-shell

# Or if using direnv
direnv allow
```

## Understanding the Code Style

### Key Macros

1. **Function Definition**
```assembly
# Function Name: my_function
# Description: What the function does
#
# Arguments:
#     a0 - first argument description
#     a1 - second argument description
# Returns:
#     a0 - return value description
#     a5 - error code (0 if successful)
fn my_function
    stack_alloc              # Allocate stack frame
    push ra, 0              # Save return address
    
    # Function body here
    
    pop ra, 0               # Restore return address
    stack_free              # Free stack frame
    ret
endfn
```

2. **System Call**
```assembly
# Make a system call
syscall SYSCALL_NAME        # Expands to proper ecall sequence
```

3. **Stack Operations**
```assembly
stack_alloc                 # Allocate stack frame
push reg, offset           # Save register to stack
pop reg, offset           # Restore register from stack
stack_free                # Free stack frame
```

4. **64-bit Operations**
```assembly
# Load 64-bit value
ldw reg_lo, reg_hi, addr   # Load 64-bit word
stw reg_lo, reg_hi, addr   # Store 64-bit word
```

### Coding Conventions

1. **Naming**
   - Functions: lowercase with underscores (e.g., `add64`)
   - Labels: descriptive, prefixed with function name
   - Constants: uppercase with underscores
   - Local labels: numbered (1:, 2:, etc.)

2. **Documentation**
   - Every function must have a header comment
   - Document arguments and return values
   - Explain complex algorithms
   - Use meaningful label names

3. **Code Organization**
   - Group related functions together
   - Use appropriate sections (.text, .data, .rodata)
   - Keep functions focused and small

## Your First Contribution

Let's walk through some common first contributions:

### 1. Adding a Math Function

Let's implement 64-bit multiplication in `lib/math64.s`:

```assembly
# Function: umul64
# Description: 64-bit unsigned multiplication
#
# Arguments:
#     a0 (alo) - least significant word of a
#     a1 (ahi) - most significant word of a
#     a2 (blo) - least significant word of b
#     a3 (bhi) - most significant word of b
# Returns:
#     a0 (rlo) - least significant word of result
#     a1 (rhi) - most significant word of result
fn umul64
    stack_alloc 24
    push ra, 0
    push s1, 4
    push s2, 8
    
    # Algorithm:
    #   r = alo * blo             # Low word multiplication
    #   r += (alo * bhi) << 32    # Cross multiplication 1
    #   r += (ahi * blo) << 32    # Cross multiplication 2
    #   r += (ahi * bhi) << 64    # High word multiplication
    
    # Your implementation here
    
    pop s2, 8
    pop s1, 4
    pop ra, 0
    stack_free 24
    ret
endfn
```

### 2. Creating a System Application

Let's create a simple "uptime" application in `apps/apps/uptime.s`:

```assembly
# Display system uptime
# author: Your Name
#
# See LICENSE file for license details.

.include "macros.s"
.include "consts.s"
.include "syscalls.s"

.section .text
.global _start

fn _start
    stack_alloc
    push ra, 0
    
    # Get system uptime
    syscall SYS_UPTIME
    
    # Convert ticks to readable format
    mv a1, a0
    la a0, fmt_uptime
    call printf
    
    # Exit program
    li a0, 0              # Exit code 0
    syscall SYS_EXIT
    
    pop ra, 0
    stack_free
    ret
endfn

.section .rodata
fmt_uptime: .string "System uptime: %d seconds\n"
```

### 3. Testing Your Changes

1. For math functions:
```bash
# Run math tests
make test TEST_NAME=math64
```

2. For system applications:
```bash
# Build application
cd apps
make
make disc

# Run in OS
cd ..
make run DRIVE=apps/disc.tar

# In QEMU shell
> uptime
```

## Common First Tasks

1. **Math Library Enhancement**
   - Add new math functions (e.g., mul64, sqrt32)
   - Optimize existing functions
   - Add test cases

2. **System Applications**
   - Create new utility applications
   - Enhance existing applications
   - Add new features to apps

3. **Documentation**
   - Improve function documentation
   - Add usage examples
   - Create tutorials

4. **Testing**
   - Add test cases
   - Improve test coverage
   - Create benchmarks

## Development Tips

### Debugging with GDB

1. Start QEMU in debug mode:
```bash
make debug TEST_NAME=math64
```

2. Connect GDB:
```bash
make gdb TEST_NAME=math64
```

3. Common GDB commands:
```gdb
break umul64           # Set breakpoint
continue              # Run until breakpoint
info registers        # View registers
stepi                # Step one instruction
x/10i $pc           # View next 10 instructions
```

## Resources

- [RISC-V Assembly Programming Guide](https://riscv-programming.org/book/riscv-book.html)
- [RISC-V Specifications](https://riscv.org/specifications/)
- [Project Wiki](https://github.com/ddrcode/riscv-os/wiki)
- [Community Chat](https://github.com/ddrcode/riscv-os/discussions)

## Getting Help

1. Check existing documentation in `docs/`
2. Read the source code comments
3. Use GitHub issues for questions
4. Join our community chat

Remember: Every expert was once a beginner. Don't be afraid to ask questions and make mistakes. Happy coding!
