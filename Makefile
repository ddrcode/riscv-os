TOOL := riscv64-none-elf
# use im and -mabi=ilp32 if planning to not use reduced base integer extension
RISC_V_EXTENSIONS := em
FLAGS := -march=rv32$(RISC_V_EXTENSIONS) -mabi=ilp32e
SRC := src/main.s src/system.s src/uart.s src/screen.s src/mem.s src/string.s src/shell.s

default: build

compile: src/main.s src/screen.s
	${TOOL}-as $(FLAGS) -I src $(SRC) -o build/riscvos.o

build: compile baremetal.ld
	${TOOL}-gcc -T baremetal.ld $(FLAGS) -nostdlib -static -o build/riscvos build/riscvos.o

run: build
	@echo "Ctrl-A C for QEMU console, then quit to exit"
	qemu-system-riscv32 -nographic -serial mon:stdio -machine virt -bios build/riscvos
	# qemu-system-riscv32 -nographic -serial pty -machine virt -bios build/riscvos
	# qemu-system-riscv32 -nographic -serial unix:/tmp/serial.socket,server -machine virt -bios build/riscvos

.PHONY: clean

clean:
	rm -f build/*
