# riscv-os
An attempt to create a tiny OS for 32-bit RISC-V implemented entirely in assembly
(the C files you find in the repo are tests only).

Currently, the OS runs on [virt](https://www.qemu.org/docs/master/system/riscv/virt.html)
and [SiFive](https://www.qemu.org/docs/master/system/riscv/sifive_u.html)
machines under QEMU.
It uses very minimalistic configuration of hardware: 4MB of RAM and 1 core.
It's also minimalistic in terms of RISC-V instruction set, as it only utilizes the E and M
extensions.

## Features

<img src="./screenshots/riscvos-screenshot.png" width="300"/>

The RISC-V OS is in very early stage of development, and currently conceptually is closer to C64's
[Kernal](https://en.wikipedia.org/wiki/KERNAL) rather than
Linux or any RTOS. Most importantly it runs on cpu's machine level, giving the user full access to
hardware and memory.

### Implemented features

- framebuffer (40x25 characters text screen, configurable),
- trivial shell with five (!!!) commands: `cls`, `date`, `print`, `prompt`, `fbdump`
- drivers for UART, RTC and PLIC
- keyboard input (UART, interrupts)
- system functions callable via `ecall`
- interrupt/exception handlers
- various math and string functions
- fallbacks for missing M-extension

### Planned features

- supervisor and user modes (currently everything executes in machine mode)
- system events

## Building and dependencies

I strongly recommend using [nix](https://nixos.org/download/#download-nix) for handling this project, as it configures all the necessary dependencies.
In such case just enter the project's folder and type `nix-shell`, or - if you use
[nix direnv](https://github.com/nix-community/nix-direnv) - `direnv allow`.

Most important Makefile options:
- `make run` - runs the system in QEMU
- `make test TEST_NAME=shell` - runs a specific test and outputs results to stdout
- `make debug TEST_NAME=shell` - loads test to QEMU and waits for connection from GDB
- `make gdb TEST_NAME=shell` - connects GDB with QEMU
Other available tests (among others): `math32`, `math64`, `string`, `rtc`

Optionally each command can be provided with `MACHINE` attribute, i.e.
`make run start MACHINE=sifive_u`. Currently, the available machines are
`virt` (default) and `sifive_u`.

### Output options

The system can be compiled with extra `OUTPUT_DEV` option, that defines how it
produces the output, i.e:

```make run OUTPUT_DEV=5```

Where the options are:
- `1` - outputs to framebuffer only (can be inspected with GDB)
- `2` - outputs to serial console
- `3` - both: framebuffer and the console. In this mode the framebuffer content can be
        dumped to the serial output with `fbdump` command
- `5` - it emulates text screen of the system with terminal's action codes

## Credits
The initial setup and linker file were inspired by
[chuckb/riscv-helloworld](https://github.com/chuckb/riscv-helloworld) project

## References
This is clearly a learning project, so I used a number of sources and
references that helped me to learn the subject. Here are the key ones:

- [Project F - FPGA & RISC-V Tutorials](https://projectf.io/posts/) -
  a collection of great, deep posts by Will Green on various aspects
  of RISC-V assembly programming. It includes a
  [cheat sheet](https://projectf.io/posts/riscv-cheat-sheet/) that I use frequently
- [An Introduction to Assembly Programming with RISC-V](https://riscv-programming.org/book/riscv-book.html) -
  very helpful free book by Prof. Edson Borin
- [RISC-V from scratch](https://twilco.github.io/riscv-from-scratch/2019/04/27/riscv-from-scratch-2.html) -
  Tyler Wilcock post on hardware layouts, linker, etc - very detailed!
  Other posts on RISC-V worth checking too.
- [Using as - the GNU Assembler](http://microelectronics.esa.int/erc32/doc/as.pdf) -
  a book by Dean Elsner, Jay Fenlason & friends
- [RISC Assembler Reference](https://michaeljclark.github.io/asm.html) -
  a very handy list of assembler directives by Michael Clark
- [Generic Virtual Platform (virt)](https://www.qemu.org/docs/master/system/riscv/virt.html) -
  A documentation of qemu's virt platform that I use for testing
- [RISC-V Options (for gcc)](https://gcc.gnu.org/onlinedocs/gcc/RISC-V-Options.html) -
  very handy list of options for compilation/building. Also, quite clear documentation of
  RISC-V extensions
