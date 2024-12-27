TOOL := riscv64-none-elf
# use im and -mabi=ilp32 if planning to not use reduced base integer extension
RISC_V_EXTENSIONS := em
FLAGS := -march=rv32$(RISC_V_EXTENSIONS) -mabi=ilp32e -g
SRC := src/system.s src/uart.s src/screen.s src/mem.s src/string.s src/shell.s src/drivers/rtc_goldfish.s
OBJ := build/obj
MACHINE := qemu-system-riscv32 -nographic -serial mon:stdio -machine virt -m 4 -smp 1

default: build_all

setup:
	mkdir -p build/obj

compile: setup src/main.s src/screen.s
	${TOOL}-as $(FLAGS) -I src $(SRC) -o $(OBJ)/riscvos.o
	${TOOL}-as $(FLAGS) -I src src/main.s -o $(OBJ)/main.o

build: compile baremetal.ld
	# ${TOOL}-gcc -T baremetal.ld $(FLAGS) -nostdlib -static -Oz -o build/riscvos $(OBJ)/main.o $(OBJ)/riscvos.o
	${TOOL}-gcc -T baremetal.ld $(FLAGS) -nostdlib -static -o build/riscvos $(OBJ)/main.o $(OBJ)/riscvos.o

compile_tests: compile tests/test_commands.s
	${TOOL}-as $(FLAGS) -I src tests/test_commands.s -o $(OBJ)/test_commands.o
	${TOOL}-as $(FLAGS) -I src tests/test_string.s -o $(OBJ)/test_string.o
	${TOOL}-as $(FLAGS) -I src tests/test_rtc.s -o $(OBJ)/test_rtc.o

build_tests: compile_tests
	${TOOL}-gcc -T baremetal.ld $(FLAGS) -nostdlib -static -o build/test_commands $(OBJ)/test_commands.o $(OBJ)/riscvos.o
	${TOOL}-gcc -T baremetal.ld $(FLAGS) -nostdlib -static -o build/test_string $(OBJ)/test_string.o $(OBJ)/riscvos.o
	${TOOL}-gcc -T baremetal.ld $(FLAGS) -nostdlib -static -o build/test_rtc $(OBJ)/test_rtc.o $(OBJ)/riscvos.o

build_all: build build_tests

run: build
	@echo "Ctrl-A C for QEMU console, then quit to exit"
	$(MACHINE) -bios build/riscvos
	# qemu-system-riscv32 -nographic -serial pty -machine virt -bios build/riscvos
	# qemu-system-riscv32 -nographic -serial unix:/tmp/serial.socket,server -machine virt -bios build/riscvos

test: build_tests
	@echo "Ctrl-A C for QEMU console, then quit to exit"
	$(MACHINE) -bios build/test_commands
	# $(MACHINE) -s -S -bios build/test_commands

.PHONY: clean debug

debug:
	gdb -ex 'target remote localhost:1234' ./build/test_commands

clean:
	rm -rf build/*

