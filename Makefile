TOOL := riscv64-none-elf
FLAGS := -march=rv32i -mabi=ilp32
SRC := src/main.s src/uart.s src/screen.s src/mem.s

default: build

compile: src/main.s src/screen.s
	${TOOL}-as $(FLAGS) -I src $(SRC) -o build/riscvos.o

build: compile baremetal.ld
	${TOOL}-gcc -T baremetal.ld $(FLAGS) -nostdlib -static -o build/riscvos build/riscvos.o

run: build
	@echo "Ctrl-A C for QEMU console, then quit to exit"
	qemu-system-riscv32 -nographic -serial mon:stdio -machine virt -bios build/riscvos

.PHONY: clean

clean:
	rm -f build/*
