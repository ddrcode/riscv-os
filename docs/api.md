# API Reference

The system exposes three layers of API:

1. **System calls** - functions of the kernel, invoked with the `ecall` instruction.
   This is the only way for a program (running in User Mode) to reach hardware.
2. **Standard library** - the functions in `lib/*.s`, linked into both the kernel
   and the programs. C prototypes live in `headers/*.h`, the Rust wrappers in
   `apps/common/riscvos-lib-rust`. Most of the library is plain code (strings, math),
   but the I/O, screen, terminal, time and file functions are thin wrappers over
   the system calls listed here.
3. **Kernel internals** - the device manager and the hardware abstraction layer (HAL),
   used by drivers and platform code. Described briefly at the end of this document.

The constants used below (`SYSFN_*`, `ERR_*`, `CFG_*`, `DEV_*`) are defined in
[`headers/consts.s`](../headers/consts.s), which is the source of truth.
The test in [`tests/test_syscall.c`](../tests/test_syscall.c) exercises the interface
described here (`make run TEST_NAME=syscall`).

## System calls

### Calling convention

| Register | Role |
|----------|------|
| `a5` | function id (one of `SYSFN_*`) |
| `a0`-`a4` | function arguments |
| `a0` | result (some functions return extra data in `a1`) |
| `a5` | error code, `0` on success (see [Error codes](#error-codes)) |

All other registers are preserved across the call. Unless stated otherwise,
`a0` is undefined on return from functions that have no result.

An unknown or unassigned function id (including `0` and ids above `SYSFN_LAST_FN_ID`)
returns `ERR_NOT_SUPPORTED` in `a5`.

System functions execute in Machine Mode, with interrupts disabled - except
`sleep` and `idle`, which wait with interrupts enabled.

In assembly use the `syscall` macro from [`headers/macros.s`](../headers/macros.s):

```assembly
.include "consts.s"
.include "macros.s"

    li a0, '!'
    syscall SYSFN_PRINT_CHAR           # expands to: li a5, SYSFN_PRINT_CHAR; ecall
    bnez a5, handle_error
```

In C and Rust prefer the library wrappers (`printc`, `sleep`, `time_now`, ...).
A raw call from C looks like this:

```c
register u32 a0 asm("a0") = '!';
register u32 a5 asm("a5") = 21;        // SYSFN_PRINT_CHAR
asm volatile("ecall" : "+r"(a0), "+r"(a5) : : "memory");
if (a5) { /* error */ }
```

### List of functions

| ID | Name | Constant | Description |
|----|------|----------|-------------|
| 1 | [`sleep`](#1-sleep) | `SYSFN_SLEEP` | suspends execution for n milliseconds |
| 2 | [`idle`](#2-idle) | `SYSFN_IDLE` | waits for the next interrupt (i.e. key press) |
| 3 | [`run`](#3-run) | `SYSFN_RUN` | loads and runs a program from the disc |
| 4 | [`exit`](#4-exit) | `SYSFN_EXIT` | ends a program and returns to the caller of `run` |
| 5 | [`get_cfg`](#5-get_cfg) | `SYSFN_GET_CFG` | reads an entry of the system configuration |
| 6 | [`get_drv_cfg`](#6-get_drv_cfg) | `SYSFN_GET_DRV_CFG` | reads configuration flags of a driver |
| 10 | [`get_secs_from_epoch`](#10-get_secs_from_epoch) | `SYSFN_GET_SECS_FROM_EPOCH` | seconds since 1970-01-01 (RTC) |
| 11 | [`get_date`](#11-get_date) | `SYSFN_GET_DATE` | current date (RTC) |
| 13 | [`get_time`](#13-get_time) | `SYSFN_GET_TIME` | current time (RTC) |
| 20 | [`get_char`](#20-get_char) | `SYSFN_GET_CHAR` | reads a byte from the standard input |
| 21 | [`print_char`](#21-print_char) | `SYSFN_PRINT_CHAR` | writes a byte to the standard output |
| 22 | [`print_str`](#22-print_str) | `SYSFN_PRINT_STR` | writes a string to the standard output |
| 30 | [`file_info`](#30-file_info) | `SYSFN_FILE_INFO` | reads file metadata |
| 31 | [`read`](#31-read) | `SYSFN_READ` | reads file content |
| 40 | [`fb_info`](#40-fb_info) | `SYSFN_FB_INFO` | framebuffer address and dimensions |
| 41 | [`fb_get_cursor`](#41-fb_get_cursor) | `SYSFN_FB_GET_CURSOR` | framebuffer cursor position |
| 42 | [`fb_set_cursor`](#42-fb_set_cursor) | `SYSFN_FB_SET_CURSOR` | moves the framebuffer cursor |
| 50 | [`set_screencode`](#50-set_screencode) | `SYSFN_SET_SCREENCODE` | maps a screen code to a Unicode glyph |
| 51 | [`video_reset`](#51-video_reset) | `SYSFN_VIDEO_RESET` | restores the default screen code table |
| 52 | [`video_switch_mode`](#52-video_switch_mode) | `SYSFN_VIDEO_SWITCH_MODE` | switches between normal and wide screen mode |

Ids 12 (`set_date`) and 14 (`set_time`) are reserved but not implemented.

### Process control

#### 1: `sleep`
Suspends execution for the given time. The kernel waits for system timer ticks
(one tick is 16 ms), so the time is rounded down to a whole number of ticks,
but at least one tick is always awaited.
- **Arguments**: `a0` - time in milliseconds
- **Returns**: nothing (`a0` is clobbered)
- **Errors**: none
- **Library**: `void sleep(u32 ms)` ([`sys_utils.h`](../headers/sys_utils.h)),
  `riscvos::sysutils::sleep`

#### 2: `idle`
Puts the CPU to sleep (`wfi`) until an interrupt other than the system timer occurs -
in practice: until the UART receives a byte. It's used by `read_line` to wait for
keyboard input without busy looping. If the standard input driver has interrupts
disabled (see [`get_drv_cfg`](#6-get_drv_cfg)) the caller should poll instead.
- **Arguments**: none
- **Returns**: nothing (`a0` is clobbered)
- **Errors**: none

#### 3: `run`
Loads a program from the disc into the program memory (`PROGRAM_RAM`, `0x80100000`,
see [`headers/config.s`](../headers/config.s)) and executes it in User Mode.
The call returns when the program calls [`exit`](#4-exit). The caller must prepare
the program arguments on the stack before the call - see [Program ABI](#program-abi).
- **Arguments**: `a0` - file id (as returned by `file_find` or in the `id` field of
  [`file_info`](#30-file_info))
- **Returns**: `a5` - exit code of the program
- **Errors**: `a5 = 1` if the file is not executable (no executable flag in the tar entry)
- **Notes**: the file id is not validated. Running a program from another program
  is not supported: there is a single program memory area and a single return address.

#### 4: `exit`
Ends the running program. Execution continues after the `run` call that started
the program, with the exit code in `a5`. When called outside of a program
(i.e. from the shell) it simply returns, with the exit code in `a5`.
- **Arguments**: `a0` - exit code (`0` for success; non-zero values are
  interpreted by the shell as [error codes](#error-codes) and printed)
- **Returns**: does not return to the program; execution resumes after `run`
  with the exit code in `a5`. Outside of a program: returns normally, with the
  exit code in `a5`.
- **Errors**: none

### System information

#### 5: `get_cfg`
Reads a single entry of the system configuration.
- **Arguments**: `a0` - configuration key (see [System configuration](#system-configuration))
- **Returns**: `a0` - value
- **Errors**: none (the key is not validated)

#### 6: `get_drv_cfg`
Reads the configuration flags of a driver. By convention bit 0 tells whether
the device is enabled; the meaning of the remaining bits is device specific
(see [Drivers](#device-manager-and-hal)). For the UART (standard input/output)
bit 1 means interrupts for incoming data are enabled.
- **Arguments**: `a0` - pointer to a driver structure (i.e. the value of
  `CFG_STD_IN`, as returned by `get_cfg`)
- **Returns**: `a0` - configuration flags
- **Errors**: none

```assembly
    li a0, CFG_STD_IN
    syscall SYSFN_GET_CFG              # a0 = driver of the standard input
    syscall SYSFN_GET_DRV_CFG          # a0 = its configuration
    andi a0, a0, 0b10                  # are input interrupts enabled?
```

### Date and time

All three functions require an RTC device (currently only the `virt` platform
has one) and fail with `ERR_NOT_SUPPORTED` otherwise.

#### 10: `get_secs_from_epoch`
- **Arguments**: none
- **Returns**: `a0` - number of seconds since 1970-01-01 00:00:00 (unsigned 32-bit)
- **Errors**: `ERR_NOT_SUPPORTED` - no RTC
- **Library**: `Result time_now(void)` ([`time.h`](../headers/time.h)),
  `riscvos::time::now`

#### 11: `get_date`
- **Arguments**: none
- **Returns**: `a0` - `Date` structure packed into a register:

  | Byte | Field | Values |
  |------|-------|--------|
  | 0 | day of month | 1-31 |
  | 1 | month | 0-11 |
  | 2 | year | year - 1900 |
  | 3 | day of week | 0-6, Monday = 0 |

- **Errors**: `ERR_NOT_SUPPORTED` - no RTC
- **Library**: `Date get_date(u32 secs)` / `date_to_str` ([`time.h`](../headers/time.h))
  convert a number of seconds obtained from `time_now` without a system call.

#### 13: `get_time`
- **Arguments**: none
- **Returns**: `a0` - `Time` structure packed into a register:

  | Byte | Field | Values |
  |------|-------|--------|
  | 0 | seconds | 0-59 |
  | 1 | minutes | 0-59 |
  | 2 | hours | 0-23 |
  | 3 | (unused) | 0 |

- **Errors**: `ERR_NOT_SUPPORTED` - no RTC
- **Library**: `Time get_time(u32 secs)` / `time_to_str` ([`time.h`](../headers/time.h))

### Input / output

The standard input and output are UART devices, configured per platform
(`CFG_STD_IN`, `CFG_STD_OUT`). Depending on the `OUTPUT_DEV` build option the
output is additionally rendered to the framebuffer and/or the terminal emulation.

#### 20: `get_char`
Reads a byte from the standard input. It never blocks: it returns `-1` when there
is nothing to read. Use [`idle`](#2-idle) to wait for input.
- **Arguments**: none
- **Returns**: `a0` - byte (0-255), or `-1` (`0xffffffff`) if no data is available
- **Errors**: none
- **Library**: `i32 getc(void)`, `i32 read_line(char*)` ([`io.h`](../headers/io.h)),
  `riscvos::io::getc`

#### 21: `print_char`
- **Arguments**: `a0` - byte to write
- **Returns**: nothing (`a0` is undefined)
- **Errors**: none
- **Library**: `void printc(char)` ([`io.h`](../headers/io.h)), `riscvos::io::printc`

#### 22: `print_str`
- **Arguments**: `a0` - pointer to a null-terminated string
- **Returns**: `a0` - `0` on success, `2` if the pointer was null (`a5` stays `0`)
- **Errors**: none
- **Library**: `void prints(const char*)`, `void println(const char*)`
  ([`io.h`](../headers/io.h)), `riscvos::io::prints`, `riscvos::io::println`

### Files

The file system is a read-only tar archive ("TarFS") mapped at `FLASH1_BASE`
(`0x22000000`). A *file id* is the offset of the file's tar header within the
archive; `0` is the first file. The library functions `file_scan_dir` and
`file_find` ([`file.h`](../headers/file.h)) iterate over the archive
using `file_info`.

#### 30: `file_info`
Fills a `FileInfo` structure for the given file.
- **Arguments**:
  - `a0` - file id
  - `a1` - pointer to a 40-byte buffer:

    | Bytes | Size | Field |
    |-------|------|-------|
    | 0-3 | 4 | file id |
    | 4-7 | 4 | size in bytes |
    | 8 | 1 | flags: bit 0 - executable, bit 1 - hidden (name starts with `.`) |
    | 9-39 | 31 | null-terminated name (max 30 characters) |

- **Returns**: `a0` - pointer to the structure (same as `a1`)
- **Errors**: none (the file id is not validated)

#### 31: `read`
Copies the content of a file to memory. There is no seeking - reading always
starts at the beginning of the file.
- **Arguments**:
  - `a0` - file id
  - `a1` - destination address
  - `a2` - number of bytes to read (truncated to the file size)
- **Returns**: `a0` - number of bytes copied
- **Errors**: none

### Framebuffer

The framebuffer is a text screen: one byte (a *screen code*) per character cell,
row by row. It exists when `OUTPUT_DEV` has bit 0 set (see [building](building.md)).
Programs normally use the library ([`screen.h`](../headers/screen.h)) rather than
these calls. There is a single framebuffer, id `0`.

#### 40: `fb_info`
- **Arguments**:
  - `a0` - framebuffer id (`0`)
  - `a1` - pointer to a 9-byte buffer (fields are not aligned):

    | Byte | Size | Field |
    |------|------|-------|
    | 0 | 1 | framebuffer id |
    | 1-4 | 4 | address of the character buffer |
    | 5-6 | 2 | cursor position (`y << 8 \| x`) |
    | 7 | 1 | height (rows) |
    | 8 | 1 | width (columns) |

- **Returns**: `a0` - address of the character buffer, or `0` if the system
  was built without a framebuffer (in which case the buffer is not filled)
- **Errors**: none

#### 41: `fb_get_cursor`
- **Arguments**: `a0` - framebuffer id
- **Returns**: `a0` - cursor position: `y << 8 | x`
- **Errors**: none

#### 42: `fb_set_cursor`
- **Arguments**: `a0` - framebuffer id, `a1` - column (x), `a2` - row (y)
- **Returns**: `a0` - new cursor position: `y << 8 | x`
- **Errors**: none (the position is not validated)

### Video / terminal

These functions control how the framebuffer is rendered on the terminal
(`OUTPUT_DEV` with bit 2 set, i.e. `OUTPUT_DEV=5`). The *screen code* table maps each
of the 256 byte values of the framebuffer to a Unicode code point; by default
it is the identity (ASCII).

#### 50: `set_screencode`
Maps a screen code to a Unicode character, e.g. to draw with block or emoji glyphs.
- **Arguments**: `a0` - screen code (0-255), `a1` - Unicode code point
- **Returns**: nothing
- **Errors**: none
- **Library**: `void term_set_screencode(byte code, u32 unicode)`
  ([`terminal.h`](../headers/terminal.h)), `riscvos::terminal::set_screencode`

#### 51: `video_reset`
Restores the default screen code table: ASCII, or in wide mode the full-width
forms `U+FF01`-`U+FF5E` and `U+3000` for space. It does not clear the screen
(use `clear_screen` from the library for that).
- **Arguments**: none
- **Returns**: nothing
- **Errors**: none
- **Library**: `void term_reset(void)`, `riscvos::terminal::reset`

#### 52: `video_switch_mode`
Switches the screen mode and resets the video. Does nothing if the mode is
already active.
- **Arguments**: `a0` - mode: `0` - normal (80x25), `1` - wide (40x25, every
  cell is rendered as a double-width glyph, i.e. full-width characters or emoji)
- **Returns**: nothing
- **Errors**: none (the mode is not validated; the shell's `screenmode` command
  accepts only `0` and `1`)
- **Library**: `term_set_mode`, `term_get_mode` ([`terminal.h`](../headers/terminal.h)),
  `riscvos::terminal::set_mode`. The library function also clears the screen
  and re-initializes it, so prefer it over the raw call.

### Error codes

Defined in [`headers/consts.s`](../headers/consts.s) (`ERR_*`); the Rust
equivalent is `riscvos::error::OSError`. The same codes are used by the shell
to report command errors and program exit codes.

| Code | Constant | Message |
|------|----------|---------|
| 0 | `ERR_UNKNOWN` | Unknown error |
| 1 | `ERR_CMD_NOT_FOUND` | Command not found |
| 2 | `ERR_MISSING_ARGUMENT` | Missing argument |
| 3 | `ERR_NOT_SUPPORTED` | Not supported |
| 4 | `ERR_INVALID_ARGUMENT` | Invalid argument |
| 5 | `ERR_STACK_OVERFLOW` | Stack overflow |

### System configuration

Keys accepted by [`get_cfg`](#5-get_cfg) (`CFG_*` in [`headers/consts.s`](../headers/consts.s)):

| Key | Constant | Value |
|-----|----------|-------|
| 0 | `INFO_OUTPUT_DEV` | the `OUTPUT_DEV` option the system was built with |
| 4 | `CFG_STD_OUT` | pointer to the UART driver used as standard output |
| 8 | `CFG_STD_IN` | pointer to the UART driver used as standard input |
| 12 | `CFG_STD_ERR` | pointer to the UART driver used as error output |
| 16 | `CFG_STD_DEBUG` | pointer to the UART driver used for debug output |
| 20 | `CFG_PLATFORM_NAME` | pointer to the platform name string (i.e. `"virt"`) |
| 24 | `CFG_SCREEN_DIMENSIONS` | `height << 16 \| width` (in characters) |
| 28 | `CFG_SCREEN_MODE` | current screen mode (`0` - normal, `1` - wide) |

### Program ABI

Programs are loaded by [`run`](#3-run) at `PROGRAM_RAM` (`0x80100000`) and
started at their first byte, in User Mode. The program runs on the stack of its
caller (the shell), which places the arguments there:

| Offset from `sp` | Size | Content |
|------------------|------|---------|
| 0 | 1 | `argc` (1 or 2) |
| 1 | 4 | `argv[0]` - pointer to the program name |
| 5 | 4 | `argv[1]` - pointer to the rest of the command line, or `0` |

A program must end with the [`exit`](#4-exit) call, invoked with the stack pointer
restored to its value at the entry. [`apps/common/startup.s`](../apps/common/startup.s)
takes care of all of this: it initializes the screen, calls C's / Rust's
`int main(int argc, char* argv[])` and exits with its return value. Program
memory layout is defined in [`apps/platforms/virt.ld`](../apps/platforms/virt.ld).

## Standard library

The library ([`lib/`](../lib)) is shared by the kernel and the programs
(`apps/build/common.o`). Function signatures are documented in the headers:

| Header | Content |
|--------|---------|
| [`io.h`](../headers/io.h) | `printc`, `prints`, `println`, `printnum`, `printw`, `getc`, `read_line` |
| [`string.h`](../headers/string.h) | `strlen`, `strcmp`, `strcpy`, `str_find_char`, `str_align_right`, `itoa`, `utoa`, `atoi` |
| [`math32.h`](../headers/math32.h), [`math64.h`](../headers/math64.h) | 32- and 64-bit integer arithmetic (`udiv32`, `udiv64`, `uadd64`, ...) |
| [`bit32.h`](../headers/bit32.h), [`bit64.h`](../headers/bit64.h) | bit manipulation |
| [`mem.h`](../headers/mem.h) | `memcpy`, `memfill`, `mem_reverse` |
| [`screen.h`](../headers/screen.h) | text screen: `clear_screen`, `scr_print`, `scr_println`, `set_cursor_pos`, `get_cursor_pos`, `scr_get_size`, ... |
| [`terminal.h`](../headers/terminal.h) | terminal control: cursor visibility, screen codes, screen mode |
| [`time.h`](../headers/time.h) | `time_now`, `get_time`, `get_date` and formatting |
| [`file.h`](../headers/file.h) | `file_scan_dir`, `file_find` |
| [`sys_utils.h`](../headers/sys_utils.h) | `sleep` |
| [`unicode.h`](../headers/unicode.h) | `utf_encode` |
| [`buffer.h`](../headers/buffer.h) | ring buffer (used by UART drivers) |

The Rust crate `riscvos` ([`apps/common/riscvos-lib-rust`](../apps/common/riscvos-lib-rust))
wraps the same functions in safe APIs (`io`, `string`, `math32`, `math64`, `bit32`,
`screen`, `terminal`, `time`, `sysutils`, `unicode`, `error`). The raw bindings
are generated from [`headers/bindings.h`](../headers/bindings.h) with bindgen.

## Shell commands

| Command | Description |
|---------|-------------|
| `cls` | clears the screen |
| `prompt <char>` | sets the prompt to the given (single) character |
| `print <text>` | prints the text |
| `platform` | prints the platform name (`virt`, `sifive_u`, `sifive_e`) |
| `screenmode <0\|1>` | switches between normal (`0`) and wide (`1`) screen mode |

Any other word is looked up as a file on the disc and, if found, executed with the
rest of the line passed as its single argument (`argv[1]`), e.g. `hello-c World`.
Programs available on the standard disc image: `ls`, `date`, `fbdump`, `hello-asm`,
`hello-c`, `hello-rust`, `clock`, `snake`, `tetris`.

Errors (unknown command, missing or invalid argument) and non-zero program exit
codes are reported with the messages from the [error codes](#error-codes) table.

## Device manager and HAL

This part of the API is internal to the kernel: used by platform initialization
(`src/platforms/<machine>.s`) and drivers (`src/drivers/`).

### Device manager ([`src/dev_mngr.s`](../src/dev_mngr.s))

Devices are registered in a table of 16 slots, addressed by byte offset:
`DEV_UART_0`..`DEV_UART_3` (0, 4, 8, 12) and `DEV_RTC_0`, `DEV_RTC_1` (16, 20).

- `device_add(a0 = device id, a1 = pointer to driver structure)` - registers a device
  (the `add_device` macro wraps it)
- `device_get(a0 = device id)` - returns the driver structure pointer in `a0`,
  or `0` if no such device

### Driver structures

Every driver is represented by a structure whose first two words are common:
the device's base address and a pointer to its `config` function. Function
pointers take the structure itself (`self`) as the first argument. C definitions
are in [`headers/hal/`](../headers/hal).

UART ([`hal/uart.h`](../headers/hal/uart.h), `DRV_UART_STRUCT_SIZE` = 24):

| Offset | Field |
|--------|-------|
| 0 | `base_addr` |
| 4 | `u32 config(self, u32 mask, u32 flags)` |
| 8 | `void putc(self, char)` |
| 12 | `i32 getc(self)` - byte, or `-1` if none available |
| 16 | `void irq_handler(self)` |
| 20 | `Buffer* buffer` - ring buffer for data received via interrupts |

RTC ([`hal/rtc.h`](../headers/hal/rtc.h), `DRV_RTC_STRUCT_SIZE` = 16):

| Offset | Field |
|--------|-------|
| 0 | `base_addr` |
| 4 | `u32 config(self, u32 mask, u32 flags)` |
| 8 | `u32 get_secs_from_epoch(self)` |
| 12 | `U64 get_raw_data(self)` - device specific raw value (`a0` - low, `a1` - high word) |

**Configuration.** `config(self, mask, flags)` updates the bits selected by `mask`
with the values from `flags` and returns the new configuration; calling it with
`mask = 0` reads the configuration (this is what `hal_get_config` and the
[`get_drv_cfg`](#6-get_drv_cfg) system function do). Bit 0 means "device enabled";
for UART bit 1 enables interrupts for incoming data and bit 2 is reserved for
outgoing-data interrupts (not implemented).

### HAL functions

Generic functions dispatching to the driver (`src/hal/`):

- `hal_get_config(a0 = self)`, `hal_set_config(a0 = self, a1 = mask, a2 = flags)`
- `uart_putc(a0 = self, a1 = char)`, `uart_puts(a0 = self, a1 = string)`,
  `uart_getc(a0 = self)`
- `rtc_get_secs_from_epoch(a0 = self)`, `rtc_read_raw_data(a0 = self)`

### Drivers

| Driver | Source | Platforms | Init function |
|--------|--------|-----------|---------------|
| NS16550A UART | `src/drivers/uart_ns16550a.s` | virt | `ns16550a_init(self, base_addr, config, irq, buffer)` |
| SiFive UART | `src/drivers/uart_sifive.s` | sifive_u, sifive_e | `sifive_uart_init(self, base_addr, config, irq, buffer)` |
| Goldfish RTC | `src/drivers/rtc_goldfish.s` | virt | `goldfish_rtc_init(self, base_addr)` |
| PLIC | `src/drivers/plic.s` | all | `plic_init`, `plic_enable_irq(irq, priority)`, `plic_disable_irq`, `plic_set_treshold`, `plic_get_source_id`, `plic_complete(irq)` |
| TarFS | `src/drivers/fs_tarfs.s` | all | (none) - backs the [file](#files) system calls |
| Video terminal | `src/drivers/video_terminal.s` | all | `video_init`, `video_repaint` - backs the [video](#video--terminal) system calls |

External interrupts are routed through the per-platform `external_irq_vector`
table in `src/platforms/<machine>.s` (PLIC source ids up to 31).
