# Hardware Support

## Requirements

- 32-bit RISC-V CPU with the E (or I) base instruction set and Zicsr
- M extension is optional - the OS emulates div/rem instructions when it is missing
- PMP support (used to protect devices from User Mode)

## Supported platforms (QEMU)

|            | virt        | sifive_u    | sifive_e                     |
|------------|-------------|-------------|------------------------------|
| RAM        | 4 MB        | 4 MB        | 16 KB (code runs from flash) |
| Screen     | 80x25       | 40x25       | 40x25                        |
| UART       | NS16550A    | SiFive (2x) | SiFive (2x)                  |
| RTC        | Goldfish    | -           | -                            |
| Disc       | pflash unit 1 | `-device loader` | -                     |
| Timer      | 10 MHz      | 1 MHz       | 32 kHz                       |

`virt` is the default and the most complete platform (the only one with a
real-time clock, so `date` and `clock` work there). On platforms without an RTC
the time functions return `ERR_NOT_SUPPORTED`.

## Supported devices

- **UART**: NS16550A (`src/drivers/uart_ns16550a.s`) and SiFive UART
  (`src/drivers/uart_sifive.s`); interrupt-driven input with a ring buffer
- **RTC**: Goldfish (`src/drivers/rtc_goldfish.s`), read-only
- **PLIC**: generic driver (`src/drivers/plic.s`), IRQ ids up to 31
  ([#21](https://github.com/ddrcode/riscv-os/issues/21))
- **Storage**: a read-only TAR disc image in memory-mapped flash
- **Display**: memory-mapped text framebuffer, rendered on the terminal
  (`src/drivers/video_terminal.s`)

## Planned hardware

- [Raspberry Pi Pico 2](https://github.com/ddrcode/riscv-os/issues/114) (RP2350,
  Hazard3 core) - the first physical target, work in progress on the `pico` branch
- [Waveshare ESP32-C6-LCD-1.47](https://github.com/ddrcode/riscv-os/issues/113)
- block devices / SD cards
  ([#72](https://github.com/ddrcode/riscv-os/issues/72),
  [#74](https://github.com/ddrcode/riscv-os/issues/74),
  [#75](https://github.com/ddrcode/riscv-os/issues/75))

## References

- [QEMU virt platform](https://www.qemu.org/docs/master/system/riscv/virt.html)
- [QEMU sifive_u platform](https://www.qemu.org/docs/master/system/riscv/sifive_u.html)
- [SiFive E31 Manual](https://sifive.cdn.prismic.io/sifive/d3ed5cd0-6e74-46b2-a12d-72b06706513e_sifive-e31-manual-v19.08.pdf)
- [16550A UART](https://www.ti.com/lit/ds/symlink/pc16550d.pdf)
- [Goldfish RTC](https://android.googlesource.com/platform/external/qemu/+/master/docs/GOLDFISH-VIRTUAL-HARDWARE.TXT)
