# Working with Raspberry Pico 2

This document describes how to set up Pico 2 for bare-metal RISC-V (Hazard3)
development with the Raspberry Pi Debug Probe.

## Prerequisites

The required tools — `openocd` (with RP2350 RISC-V support), `picotool`, and
`riscv64-none-elf-gdb` — are pulled in by the project's `shell.nix`. Run
`direnv allow` (or `nix-shell`) in the repo root before any of the commands
below.

## Hardware setup

- Probe **DBG** connector → 3-pin SWD ribbon → Pico 2's debug header (the
  3-pin header next to the USB connector: SWCLK, GND, SWDIO).
- Probe **UART** connector → 3-pin ribbon → Pico 2 GP0/GP1 — optional, but
  gives you a USB-attached serial console alongside the debug session.
- Both the probe and the Pico 2 each need their own USB cable. The probe
  does **not** power the target.

## Debugging session

Assumes you've built `blinky.elf` (or your kernel ELF) — see the "Test
application" section below for a self-contained example.

1. **Once per power-on / session.** Tell the chip to come up in RISC-V mode
   on its next reset:
   ```sh
   picotool reboot -u -c riscv
   ```
   The selection persists until you set it back to ARM (`-c arm`) or the
   chip loses power.

2. **Start OpenOCD** (terminal 1):
   ```sh
   openocd \
       -c "adapter speed 1000" \
       -f interface/cmsis-dap.cfg \
       -c "set USE_CORE 0" \
       -f target/rp2350-riscv.cfg
   ```
   Look for `Hardware thread awareness created` and CMSIS-DAP enumeration
   info. `Error connecting DP: cannot read IDR` means the SWD wiring is
   wrong or the target isn't powered.

3. **Start GDB** (terminal 2):
   ```sh
   gdb -ex "set architecture riscv:rv32" blinky.elf
   ```
   The `set architecture` flag is required because `riscv64-none-elf-gdb`
   defaults to rv64. To avoid retyping it, drop a `.gdbinit` into the same
   folder with that one line.

4. **Inside GDB:**
   ```gdb
   target extended-remote localhost:3333
   monitor reset halt
   load
   continue
   ```
   - `monitor reset halt` puts the chip into a clean halted state at the
     reset vector.
   - `load` writes the ELF sections to wherever the linker script placed
     them (see FLASH-vs-SRAM note below) and sets PC to `e_entry`.
   - `continue` runs the program. Use `stepi` instead if you want to walk
     instruction by instruction from `_start`.

## Test application to verify the setup

A self-contained blinky for GPIO25 — the onboard LED on plain Pico 2 (**not**
Pico 2 W, where the LED is on the wireless module and unreachable through
GPIO).

### `blinky.s`

```asm
.equ IO_BANK0_BASE,      0x40028000
.equ PADS_BANK0_BASE,    0x40038000
.equ ATOMIC_CLR_OFFSET,  0x3000

.equ GPIO25_CTRL,        IO_BANK0_BASE + 0x0cc
.equ GPIO25_PAD,         PADS_BANK0_BASE + 0x68

.equ GPIO_FUNC_SIO,      5
.equ PAD_ISO_BIT,        (1 << 8)

.equ SIO_BASE,           0xd0000000
.equ GPIO_OUT,           SIO_BASE + 0x010
.equ GPIO_OE,            SIO_BASE + 0x030
.equ GPIO_25,            (1 << 25)

.equ DELAY_COUNT,        5000000

.global _start

.section .text
.align 4

_start:
    # Clear GPIO25 pad isolation (RP2350-specific; not needed on RP2040)
    li a0, GPIO25_PAD + ATOMIC_CLR_OFFSET
    li a1, PAD_ISO_BIT
    sw a1, 0(a0)

    # Select SIO function for GPIO25
    li a0, GPIO25_CTRL
    li a1, GPIO_FUNC_SIO
    sw a1, 0(a0)

    # Enable output drive for GPIO25 only
    li a0, GPIO_OE
    li a1, GPIO_25
    sw a1, 0(a0)

    # Toggle pattern: s1 alternates between GPIO_25 and 0
    li s1, GPIO_25
    add t0, s1, zero
    li a0, GPIO_OUT

loop:
    sw s1, 0(a0)           # drive GPIO_OUT = s1
    li a2, DELAY_COUNT
1:  addi a2, a2, -1
    bnez a2, 1b
    xor s1, s1, t0         # flip bit 25 in s1
    j loop
```

### `linker.ld`

```ld
ENTRY(_start)

MEMORY
{
    FLASH(rx)  : ORIGIN = 0x10000000, LENGTH = 2048K
    RAM(rwx)   : ORIGIN = 0x20000000, LENGTH = 512K
}

SECTIONS
{
    . = ORIGIN(FLASH);

    .text : {
        KEEP(*(.text._start))
        *(.text*)
    } > FLASH

    .rodata : {
        *(.rodata*)
    } > FLASH

    .data : {
        __data_start = .;
        *(.data*)
        __data_end = .;
    } > RAM AT > FLASH

    __data_load = LOADADDR(.data);

    .bss : {
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        __bss_end = .;

        PROVIDE(__global_pointer$ = . + 0x800);
    } > RAM

    PROVIDE(__stack_top = ORIGIN(RAM) + LENGTH(RAM));
}
```

### FLASH vs SRAM — which to choose

The linker script above places `.text` in FLASH (`0x10000000`). With this
layout every `gdb load` actually programs the XIP flash — durable across
power cycles, but slow per iteration.

For fast bring-up iteration, change the location counter and the `.text`
section to live in SRAM:

```ld
SECTIONS
{
    . = ORIGIN(RAM);

    .text : {
        KEEP(*(.text._start))
        *(.text*)
    } > RAM
    ...
}
```

Now `gdb load` writes to SRAM (near-instant) at the cost of needing the
probe attached every time — the chip forgets your code on power-off.
Switch back to FLASH when you want standalone boot.

### Build

```sh
riscv64-none-elf-as -mabi=ilp32e -march=rv32em_zicsr -o blinky.o blinky.s
riscv64-none-elf-ld  -Arv32em_zicsr -melf32lriscv -T linker.ld -static -nostdlib \
                     -o blinky.elf blinky.o
```

`-mabi=ilp32e -march=rv32em_zicsr` matches the OS's ISA philosophy (minimum
profile; see the project's design notes).

## Deployment without the probe (UF2)

You can convert the ELF to a UF2 with `elf2uf2` or `picotool uf2 convert`,
drag it onto the Pico 2 in BOOTSEL mode, and have it flashed.

**Caveat:** RP2350 will not boot a flashed image from power-on unless it
contains an `IMAGE_DEF` block — the metadata that tells the bootrom this
is a RISC-V image and where to enter. Without the block, the chip will
sit at the BOOTSEL prompt forever after power-cycle.

For the development loop above you don't need to care: probe + `gdb load`
bypasses the bootrom entirely. When you eventually want standalone boot,
either add an `IMAGE_DEF` block at the start of `_start` (Pico SDK has the
canonical layout) or use `picotool sign` to attach one.
