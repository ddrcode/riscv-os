# Working with Raspberry Pico 2

This document describes how to setup Pico 2 for development and running the system.

## Debugging with Pico Probe

1. Connect the probe according to the specification
2. Once per session run: `picotool reboot -u -c riscv`
3. run
   ```sh
    openocd \
        -c "adapter speed 1000"  \
        -f interface/cmsis-dap.cfg \
        -c "set USE_CORE 0" \
        -f target/rp2350-riscv.cfg
   ```
4. Start gdb session: `gdb -ex "set architecture riscv:rv32" kernel.elf`
5. In gdb run:
   ```gdb
   target extended-remote localhost:3333
   monitor reset halt
   load
   ```



