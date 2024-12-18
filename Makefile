TOOL := riscv64-none-elf
FLAGS := -march=rv32i -mabi=ilp32

default: build

compile: src/main.s src/screen.s
	${TOOL}-as $(FLAGS) -I src src/main.s src/screen.s -o build/riscvos.o

build: compile baremetal.ld
	${TOOL}-gcc -T baremetal.ld $(FLAGS) -nostdlib -static -o build/riscvos build/riscvos.o

run: build
	@echo "Ctrl-A C for QEMU console, then quit to exit"
	qemu-system-riscv32 -nographic -serial mon:stdio -machine virt -bios build/riscvos

.PHONY: clean

clean:
	rm -f build/*
