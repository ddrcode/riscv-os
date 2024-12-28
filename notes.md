# Notes

Notes, links and hints that helped me to develop the project.


## QEMU

Finding addresses of memory devices: `info mtree`

### Syscalls / `ecall`
- [Who provides syscalls in qemu-riscv?](https://stackoverflow.com/questions/52723900/who-provides-syscalls-in-qemu-riscv)
- [riscv-probe](https://github.com/michaeljclark/riscv-probe)

## Devices / drivers

### UART / serial / chardev
- [Chardev device options](https://www.qemu.org/docs/master/system/invocation.html#hxtool-6)
- Try chardev: `qemu-system-riscv64 -nographic -M virt -cpu rv64 -m 4G -smp $(QEMU_N_HARTS) -serial pty -bios
opensbi/output/path/fw_payload.elf -device virtio-serial-device -chardev pty,id=serial3 -device
virtconsole,chardev=serial3 -S -gdb tcp:localhost:9000`

### GoldfishRTC

- Memory: `0000000000101000-0000000000101023 (prio 0, i/o): goldfish_rt`
- [Goldfish docs](https://android.googlesource.com/platform/external/qemu/+/master/docs/GOLDFISH-VIRTUAL-HARDWARE.TXT)
- [Risc-V patch for qemu](https://lists.sr.ht/~philmd/qemu/patches/8697)
- [Implementationf of Goldfish in
Linux](https://github.com/torvalds/linux/blob/master/drivers/rtc/rtc-goldfish.c#L110)
- [Implementation of rtc_time64_to_tm](https://elixir.bootlin.com/linux/v6.12.6/source/drivers/rtc/lib.c#L142)

## Linker

- [setting initial value of __global_pointer$](https://gnu-mcu-eclipse.github.io/arch/riscv/programmer/#the-gp-global-pointer-register)

## Make

- [How patterns match](https://www.gnu.org/software/make/manual/html_node/Pattern-Match.html)
- [Automatic variables](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html)

## Minicom

- Connect via socket: `minicom -D unix\#/tmp/xxx`

