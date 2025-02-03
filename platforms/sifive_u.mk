QEMU_MACHINE_CONFIG := -smp 2

DRIVERS := plic.s uart_sifive.s video_terminal.s fs_tarfs.s

ifdef DRIVE
    QEMU_MACHINE_CONFIG += -device loader,file=$(DRIVE),addr=0x20000000
endif
