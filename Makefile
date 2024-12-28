TOOL := riscv64-none-elf
# use im and -mabi=ilp32 if planning to not use reduced base integer extension
RISC_V_EXTENSIONS := em
FLAGS := -march=rv32$(RISC_V_EXTENSIONS) -mabi=ilp32e -g
AS_FLAGS := -I include
SRC := src/system.s src/screen.s src/mem.s src/string.s src/shell.s src/math.s src/drivers/uart.s src/drivers/rtc_goldfish.s
OBJ := build/obj
QEMU := qemu-system-riscv32 -machine virt -m 4 -smp 1
MACHINE = $(QEMU) -nographic -serial mon:stdio

# TEST_OBJS := $(patsubst %.s,%.o,$(wildcard tests/test_*))
TEST_OBJS = test_commands.o test_string.o test_rtc.o
TESTS = test_commands test_string test_rtc
TEST_NAME ?= commands

default: build_all

setup:
	mkdir -p build/obj

compile: setup src/main.s src/screen.s
	${TOOL}-as $(FLAGS) $(AS_FLAGS) $(SRC) -o $(OBJ)/riscvos.o
	${TOOL}-as $(FLAGS) $(AS_FLAGS) src/main.s -o $(OBJ)/main.o

build: compile baremetal.ld
	# ${TOOL}-gcc -T baremetal.ld $(FLAGS) -nostdlib -static -Oz -o build/riscvos $(OBJ)/main.o $(OBJ)/riscvos.o
	${TOOL}-gcc -T baremetal.ld $(FLAGS) -nostdlib -static -o build/riscvos $(OBJ)/main.o $(OBJ)/riscvos.o

# $(TEST_OBJS): %o: tests/%s
# 	${TOOL}-as $(FLAGS) $(AS_FLAGS) $< -o $(OBJ)/$@

%.o: tests/%.s
	${TOOL}-as $(FLAGS) $(AS_FLAGS) $< -o $(OBJ)/$@

compile_tests: setup $(TEST_OBJS)

$(TESTS): %.o:
# %: build/obj/test%.o
	@echo "1:" $< ", 2: " $@
	${TOOL}-gcc -T baremetal.ld $(FLAGS) -nostdlib -static -o build/$@ $(OBJ)/$@.o $(OBJ)/riscvos.o

build_tests: compile compile_tests $(TESTS)

build_all: build build_tests

run: build
	@echo "Ctrl-A C for QEMU console, then quit to exit"
	$(MACHINE) -bios build/riscvos
	# qemu-system-riscv32 -nographic -serial pty -machine virt -bios build/riscvos
	# qemu-system-riscv32 -nographic -serial unix:/tmp/serial.socket,server -machine virt -bios build/riscvos

test: build_tests
	@echo "Ctrl-A C for QEMU console, then quit to exit"
	$(MACHINE) -bios build/test_$(TEST_NAME)

.PHONY: clean gdb debug

debug: build_tests
	@echo "Ctrl-A C for QEMU console, then quit to exit"
	$(MACHINE) -s -S -bios build/test_$(TEST_NAME)

gdb:
	gdb -ex 'target remote localhost:1234' ./build/test_$(TEST_NAME)

clean:
	rm -rf build/*

