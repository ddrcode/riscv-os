# Building and Running

## Prerequisites

The nix shell provides everything: RISC-V binutils and gcc, QEMU, rustup,
bindgen, minicom, dtc and ccls. Run `nix-shell` (or `direnv allow`) in the
repository root - it covers `apps/` too. The nixpkgs revision is pinned in
`nixpkgs.nix`; GDB is included on Linux.

Without nix: install RISC-V binutils/gcc and qemu-system-riscv32 manually,
plus rustup for the Rust programs (the toolchain is pinned in
`apps/rust-toolchain.toml` and installed by rustup automatically).

## Building

```bash
make                    # OS binary for the default machine (virt)
cd apps && make disc    # applications disc image (apps/disc.tar)
```

## Running

```bash
make run                            # just the OS
make run DRIVE=apps/disc.tar        # with the applications disc
make run MACHINE=sifive_u DRIVE=apps/disc.tar
```

Machines: `virt` (default), `sifive_u`, `sifive_e` (no disc support).
Inside QEMU press `Ctrl-Q C` for the QEMU console; `quit` exits.

The `OUTPUT_DEV` option selects the output device(s) - see the
[README](../README.md#output-options). The default is `5` (screen rendered on
the terminal); tests use `3` (plain text on the serial console).

Build artifacts land in `build/`, with object files separated per machine and
output device, so switching `MACHINE` or `OUTPUT_DEV` needs no `make clean`.

## Tests

```bash
make test                           # all self-terminating tests
make test TESTS="math64 string"     # a subset
make run TEST_NAME=math64           # a single test, output on the console
```

The remaining tests (`uart`, `terminal`, `shell`, `stack`) are interactive -
run them with `make run TEST_NAME=...`.

## Debugging

```bash
make debug TEST_NAME=math64         # terminal 1: QEMU waits for GDB
make gdb TEST_NAME=math64           # terminal 2: connect GDB
```

The same works for the whole system: `make debug` and `make gdb`.

## Release build

```bash
make release                        # optimized, stripped build/virt.bin
```
