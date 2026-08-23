# Development Guide

## Project structure

```
riscv-os/
├── apps/            # programs, built separately (see apps/Makefile)
│   ├── apps/        # one directory per program (Assembly, C, Rust)
│   ├── common/      # program startup code and the Rust library (riscvos crate)
│   └── platforms/   # program linker scripts
├── docs/
├── headers/         # C headers of the library + assembly constants and macros
│   ├── drivers/     # driver headers
│   ├── hal/         # driver structures (HAL)
│   └── platforms/   # per-machine constants (memory map, devices)
├── lib/             # standard library, linked into the OS and the programs
├── platforms/       # per-machine linker scripts and make configuration
├── src/             # the kernel
│   ├── drivers/
│   ├── hal/
│   └── platforms/   # per-machine initialization and IRQ routing
└── tests/           # tests, executed in QEMU (make test)
```

Key files: `src/startup.s` (boot), `src/irq.s` (interrupts and exceptions),
`src/system.s` (core system functions), `src/sysfn.s` (system call handlers),
`src/shell.s`, `headers/config.s` + `headers/consts.s` + `headers/macros.s`
(configuration, constants, macros).

## Coding conventions

- functions and labels: lowercase with underscores (`read_line`, `uart_0_buffer:`)
- constants: uppercase with underscores (`SYSFN_SLEEP`)
- local labels: numbered (`1:`, `2:`)
- every function has a header comment describing arguments, returned values and
  the error code; structures get a table-like comment (byte, length, meaning)
- group related functions; use `.text`/`.data`/`.rodata` sections appropriately
- every exit path must restore exactly what the entry path saved

Function template:

```assembly
# Description of what the function does
# Arguments:
#     a0 - first argument
# Returns:
#     a0 - result
#     a5 - error code (0 on success)
fn my_function
    stack_alloc                        # allocates the frame, saves ra
    push s1, 8                         # save the registers you use

    # function body

    pop s1, 8
    stack_free                         # restores ra, frees the frame
    ret
endfn
```

The macros (`fn`, `stack_alloc`, `push`, `syscall`, ...) are defined in
[`headers/macros.s`](../headers/macros.s).

## Adding a new system call

1. Add the `SYSFN_*` constant in `headers/consts.s`
2. Implement the handler in `src/sysfn.s`: arguments in `a0`-`a4`, result in
   `a0`, error code in `a5` (the dispatcher zeroes `a5` beforehand)
3. Add the handler to `sysfn_vector` (same file)
4. Document it in [`docs/api.md`](api.md)
5. Add a case to `tests/test_syscall.c`

## Adding a new driver

1. Create the driver in `src/drivers/`, implementing the structure from
   `headers/hal/` (base address + function pointers)
2. Register it in the platform's `platform_start` (`add_device` macro) and route
   its interrupt in the platform's `external_irq_vector`
3. Add the source file to `DRIVERS` in `platforms/<machine>.mk`

## Adding a new platform

1. `src/platforms/<machine>.s` - `platform_start` and `external_irq_vector`
2. `headers/platforms/config-<machine>.s` - memory map, devices, screen size
3. `platforms/<machine>.ld` and `platforms/<machine>.mk` - linker script,
   drivers list, QEMU options
4. Register the machine in `headers/config.s`

## Testing

Tests live in `tests/`, written in C or assembly, and are linked with the kernel
objects (minus `main`); the helpers are in `headers/assert.h`. A test prints its
results and a summary line, which `tests/run.sh` uses to stop QEMU and report
the outcome.

```bash
make test                        # all self-terminating tests
make test TESTS="math64 string"  # a subset
make run TEST_NAME=math64        # single test, interactively
```

A new self-terminating test: add `tests/test_<name>.c` and add `<name>` to
`TESTS` in the `Makefile`.

## Debugging

```bash
make debug TEST_NAME=math64      # QEMU waits for GDB
make gdb TEST_NAME=math64        # in a second terminal
```

Useful GDB commands: `break <function>`, `stepi`, `info registers`,
`x/10i $pc`, `x/Nx <addr>`, `continue`.

## Contributing

Fork, create a branch, follow the conventions above, add tests and update the
docs, open a pull request. Issues labeled
[good first issue](https://github.com/ddrcode/riscv-os/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)
are a good place to start.

## Resources

- [RISC-V Specifications](https://riscv.org/specifications/)
- [An Introduction to Assembly Programming with RISC-V](https://riscv-programming.org/book/riscv-book.html)
- [Project issues](https://github.com/ddrcode/riscv-os/issues)
