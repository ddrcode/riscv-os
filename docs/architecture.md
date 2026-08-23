# Architecture

RISC-V OS is a minimalistic operating system for 32-bit RISC-V, written in
assembly. It resembles C64's Kernal: a single program runs at a time, on top of
a small set of system services. There is no scheduler, no MMU and no dynamic
memory (yet - see [#101](https://github.com/ddrcode/riscv-os/issues/101)).

## Boot sequence

1. `src/startup.s` (`_start`): sets `gp` and `sp`, parks all harts except hart 0
2. `platform_start` (`src/platforms/<machine>.s`): initializes interrupts and the
   PLIC, configures the drivers, registers devices, fills the system config
3. `sysinit` (`src/system.s`): sets up PMP and the output devices
4. `mret` drops to User Mode into `main`, which starts the shell

## Memory layout (virt)

| Address       | Content                                             |
|---------------|-----------------------------------------------------|
| `0x0010_1000` | Goldfish RTC                                        |
| `0x0C00_0000` | PLIC                                                |
| `0x1000_0000` | UART0 (NS16550A)                                    |
| `0x2200_0000` | FLASH1 - the disc image (TAR)                       |
| `0x8000_0000` | RAM start; kernel code and data (~24 KB)            |
| `0x8010_0000` | program area, 256 KB (`PROGRAM_RAM` in `headers/config.s`) |
| `0x8040_0000` | RAM end; the stack grows down from here             |

There is one 4 KB stack shared by the kernel, the shell and the running program
(its health is verified by `check_stack` on every timer tick), plus a separate
4 KB stack for interrupt handlers.

## Privilege modes and memory protection

- **Machine Mode** - trap handlers, system functions, drivers
- **User Mode** - the shell and the programs
- **PMP** - RAM is readable/writable/executable for User Mode; everything outside
  RAM (devices, flash) is machine-only, so hardware is reachable only through
  system calls. Supervisor mode is not used
  ([#42](https://github.com/ddrcode/riscv-os/issues/42)).

## Interrupts and exceptions (`src/irq.s`)

- vectored `mtvec`; handled interrupts: machine timer (16 ms tick), machine
  external (PLIC) and machine software
- external interrupts are routed through a per-platform `external_irq_vector`
- exceptions go through `exceptions_vector`: `ecall` from User Mode is the system
  call entry; illegal M-extension instructions (div, rem, ...) are emulated in
  software when the hardware lacks the extension (`HAS_EXTENSION_M=0`)
- the timer tick also drives the terminal repaint (with `OUTPUT_DEV=5`)

## System calls

`ecall` with the function id in `a5`, arguments in `a0`-`a4`, result in `a0` and
the error code in `a5`. The complete reference is in [api.md](api.md).

## Hardware abstraction layer

A driver is a structure: base address plus function pointers, registered in the
device manager under a well-known id (`DEV_UART_0`, `DEV_RTC_0`, ...). The system
configuration (`cfg_get`/`cfg_set`) stores pointers to the standard input/output
devices, the platform name and the screen settings. Details in
[api.md](api.md#device-manager-and-hal).

## File system

A read-only TAR archive ("TarFS") mapped at `FLASH1_BASE`; a file id is the
offset of the file's tar header. `run` copies a program to `PROGRAM_RAM` and
executes it in User Mode; `exit` returns to the shell.

## Video pipeline

Programs print into a text framebuffer (one byte per character cell). With
`OUTPUT_DEV=5` the video driver compares the framebuffer with its previous state
on every timer tick and sends only the changed cells to the terminal as escape
codes. A 256-entry screen-code table maps cell values to Unicode glyphs; the wide
mode (40x25) renders every cell as a double-width glyph.

## Platforms

|            | virt      | sifive_u  | sifive_e                  |
|------------|-----------|-----------|---------------------------|
| RAM        | 4 MB      | 4 MB      | 16 KB (code runs from flash) |
| Screen     | 80x25     | 40x25     | 40x25                     |
| UART       | NS16550A  | SiFive x2 | SiFive x2                 |
| RTC        | Goldfish  | -         | -                         |
| Disc       | pflash    | loader    | -                         |

Per-machine code and configuration: `src/platforms/<machine>.s`,
`headers/platforms/config-<machine>.s`, `platforms/<machine>.ld` and
`platforms/<machine>.mk`.
