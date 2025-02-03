DRIVERS := plic.s rtc_goldfish.s uart_ns16550a.s video_terminal.s fs_tarfs.s

QEMU_MACHINE_CONFIG := -m 4 -smp 1

ifdef DRIVE
    QEMU_MACHINE_CONFIG += -drive file=$(DRIVE),format=raw,if=pflash,unit=1
endif
