TOOL := riscv64-none-elf
# use im and -mabi=ilp32 if planning to not use reduced base integer extension
RISC_V_EXTENSIONS := em
FLAGS := -march=rv32$(RISC_V_EXTENSIONS) -mabi=ilp32e
SRC := src/system.s src/uart.s src/screen.s src/mem.s src/string.s src/shell.s
OBJ := build/obj

default: build_all

setup:
	mkdir -p build/obj

compile: setup src/main.s src/screen.s
	${TOOL}-as $(FLAGS) -I src $(SRC) -o $(OBJ)/riscvos.o
	${TOOL}-as $(FLAGS) -I src src/main.s -o $(OBJ)/main.o

build: compile baremetal.ld
	${TOOL}-gcc -T baremetal.ld $(FLAGS) -nostdlib -static -o build/riscvos $(OBJ)/main.o $(OBJ)/riscvos.o

compile_tests: compile tests/test_commands.s
	${TOOL}-as $(FLAGS) -I src tests/test_commands.s -o $(OBJ)/test_commands.o
	${TOOL}-as $(FLAGS) -I src tests/test_string.s -o $(OBJ)/test_string.o

build_tests: compile_tests
	${TOOL}-gcc -T baremetal.ld $(FLAGS) -nostdlib -static -o build/test_commands $(OBJ)/test_commands.o $(OBJ)/riscvos.o
	${TOOL}-gcc -T baremetal.ld $(FLAGS) -nostdlib -static -o build/test_string $(OBJ)/test_string.o $(OBJ)/riscvos.o

build_all: build build_tests

run: build
	@echo "Ctrl-A C for QEMU console, then quit to exit"
	qemu-system-riscv32 -nographic -serial mon:stdio -machine virt -bios build/riscvos
	# qemu-system-riscv32 -nographic -serial pty -machine virt -bios build/riscvos
	# qemu-system-riscv32 -nographic -serial unix:/tmp/serial.socket,server -machine virt -bios build/riscvos

test: build_tests
	@echo "Ctrl-A C for QEMU console, then quit to exit"
	qemu-system-riscv32 -nographic -serial mon:stdio -machine virt -bios build/test_string

.PHONY: clean

clean:
	rm -rf build/*
