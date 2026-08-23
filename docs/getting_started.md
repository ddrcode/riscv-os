# Getting Started

This guide walks you from a fresh clone to your first own program running on the OS.

## Setup

```bash
git clone https://github.com/ddrcode/riscv-os.git
cd riscv-os
nix-shell            # or `direnv allow` if you use nix-direnv
```

The repository contains both the system and the programs (`apps/`); the single
nix shell provides the complete toolchain for both (see
[building.md](building.md) for the details and for working without nix).

Check that everything works:

```bash
make test                         # the test suite, a few seconds
cd apps && make disc && cd ..     # the applications disc
make run DRIVE=apps/disc.tar      # boot the system; try: ls, date, snake
```

## Understanding the code style

Functions are written with the macros from
[`headers/macros.s`](../headers/macros.s):

```assembly
fn my_function
    stack_alloc 16             # allocate a 16-byte stack frame, save ra
    push s0, 8                 # save a register (word at byte 8 of the frame)

    # function body

    pop s0, 8
    stack_free 16              # restore ra, free the frame
    ret
endfn
```

System functions are invoked with the `syscall` macro; the function ids and
other constants live in [`headers/consts.s`](../headers/consts.s), the complete
reference in [api.md](api.md):

```assembly
li a0, '!'
syscall SYSFN_PRINT_CHAR       # expands to: li a5, SYSFN_PRINT_CHAR; ecall
bnez a5, handle_error          # a5 holds the error code (0 = success)
```

Conventions (naming, comments, structure) are described in
[development.md](development.md#coding-conventions).

## Your first program

Programs live in `apps/apps/`, one directory each. Create
`apps/apps/greet/greet.s`:

```assembly
# Prints a greeting
.include "consts.s"
.include "macros.s"

.section .text
.global main

fn main
    stack_alloc
    la a0, msg
    call println               # the standard library (lib/) is linked in
    setz a0                    # exit code
    stack_free
    ret
endfn

.section .rodata
msg: .string "Hello from my first program!"
```

Then:

1. Copy `apps/apps/hello-asm/hello-asm.mk` to `apps/apps/greet/greet.mk` and
   change the `ELF` name and the source file in it.
2. Add `greet` to the `APPS` list in `apps/Makefile`.
3. Build and run:

```bash
cd apps && make disc && cd ..
make run DRIVE=apps/disc.tar
> greet
Hello from my first program!
```

Programs receive `argc`/`argv` (see [api.md](api.md#program-abi)) and can also
be written in C (`apps/apps/hello-c`) or Rust (`apps/apps/hello-rust`, using the
`riscvos` crate from `apps/common`).

## First contributions

- issues labeled
  [good first issue](https://github.com/ddrcode/riscv-os/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) -
  e.g. [#41](https://github.com/ddrcode/riscv-os/issues/41), multiplication
  functions in `lib/math32.s`
- a new program for the disc (a tool, a game, a demo)
- new test cases in `tests/` (`make test TESTS=<name>` runs one suite)
- documentation fixes

## Debugging

```bash
make debug TEST_NAME=math64    # terminal 1: QEMU waits for GDB
make gdb TEST_NAME=math64      # terminal 2
```

Handy GDB commands: `break umul64`, `continue`, `stepi`, `info registers`,
`x/10i $pc`.

## Resources

- [RISC-V Assembly Programming book](https://riscv-programming.org/book/riscv-book.html)
- [RISC-V cheat sheet](https://projectf.io/posts/riscv-cheat-sheet/)
- [Project issues](https://github.com/ddrcode/riscv-os/issues) - questions welcome
