TOOL := riscv64-none-elf
# use im and -mabi=ilp32 if planning to not use reduced base integer extension
RISC_V_EXTENSIONS := em
FLAGS := -march=rv32$(RISC_V_EXTENSIONS) -mabi=ilp32e -g
AS_FLAGS := -I headers
GCC_FLAGS := -T baremetal.ld -nostdlib -static -I headers
SRC := src/system.s src/screen.s src/mem.s src/string.s src/shell.s src/bit32.s src/bit64.s src/math32.s src/math64.s src/drivers/uart.s src/drivers/rtc_goldfish.s
OBJ := build/obj

QEMU_EXTENSIONS := e=on,m=on,i=off,h=off,f=off,d=off,a=off,f=off,c=off,zawrs=off,sstc=off,zicntr=off,zihpm=off,zicboz=off,zicbom=off,svadu=off
QEMU := qemu-system-riscv32 -machine virt -m 4 -smp 1 -cpu rv32,$(QEMU_EXTENSIONS)
MACHINE = $(QEMU) -nographic -serial mon:stdio -echr 17

# TEST_OBJS := $(patsubst %.s,%.o,$(wildcard tests/test_*))
TEST_OBJS = test_commands.o test_string.o test_rtc.o test_stack.o test_math32.o
TESTS = test_commands test_string test_rtc test_stack test_math32
TEST_NAME ?= commands


SRC := $(wildcard src/*.s)
SRC_NO_MAIN := $(filter-out src/main.s, $(SRC))
OBJ_DIR := build/obj
OBJ_FILES := $(addprefix $(OBJ_DIR)/, $(patsubst %.s, %.o, $(notdir $(SRC))))
OBJ := $(patsubst %.s, %.o, $(notdir $(SRC)))

DRIVERS_SRC := $(wildcard src/drivers/*.s)
DRIVERS_OBJ := $(patsubst %.s, %.o, $(notdir $(DRIVERS_SRC)))
OBJ_FILES += $(addprefix $(OBJ_DIR)/, $(patsubst %.s, %.o, $(notdir $(DRIVERS_SRC))))

default: build_all

setup:
	mkdir -p build/obj

$(OBJ): %.o: src/%.s
	${TOOL}-as $(AS_FLAGS) $(FLAGS) -o $(OBJ_DIR)/$@ $<

$(DRIVERS_OBJ): %.o: src/drivers/%.s
	${TOOL}-as $(AS_FLAGS) $(FLAGS) -o $(OBJ_DIR)/$@ $<

compile: setup $(OBJ) $(DRIVERS_OBJ)

build: compile baremetal.ld
	# ${TOOL}-gcc -T baremetal.ld $(FLAGS) -nostdlib -static -Oz -o build/riscvos $(OBJ)/main.o $(OBJ)/riscvos.o
	${TOOL}-gcc $(FLAGS) $(GCC_FLAGS) -o build/riscvos.elf $(OBJ_FILES)

# $(TEST_OBJS): %o: tests/%s
# 	${TOOL}-as $(FLAGS) $(AS_FLAGS) $< -o $(OBJ)/$@

%.o: tests/%.s
	${TOOL}-as $(FLAGS) $(AS_FLAGS) $< -o $(OBJ)/$@

compile_tests: setup $(TEST_OBJS)

$(TESTS): %.o:
# %: build/obj/test%.o
	@echo "1:" $< ", 2: " $@
	${TOOL}-gcc $(FLAGS) $(GCC_FLAGS) -o build/$@ $(OBJ)/$@.o $(OBJ)/riscvos.o

build_tests: compile compile_tests $(TESTS)
	$(TOOL)-gcc $(FLAGS) $(GCC_FLAGS) -o $(OBJ)/assert.o -c tests/assert.c
	$(TOOL)-gcc $(FLAGS) $(GCC_FLAGS) -o $(OBJ)/test_math64.o -c tests/test_math64.c
	$(TOOL)-as $(FLAGS) $(AS_FLAGS) -o $(OBJ)/startup.o tests/startup.s tests/helpers.s
	$(TOOL)-gcc $(FLAGS) $(GCC_FLAGS) -o build/test_math64 $(OBJ)/startup.o $(OBJ)/assert.o $(OBJ)/test_math64.o $(OBJ)/riscvos.o

build_all: build build_tests

run: build
	@echo "Ctrl-Q C for QEMU console, then quit to exit"
	$(MACHINE) -bios build/riscvos.elf
	# qemu-system-riscv32 -nographic -serial pty -machine virt -bios build/riscvos
	# qemu-system-riscv32 -nographic -serial unix:/tmp/serial.socket,server -machine virt -bios build/riscvos

test: build_tests
	@echo "Ctrl-Q C for QEMU console, then quit to exit"
	$(MACHINE) -bios build/test_$(TEST_NAME)

c: div64.c
	${TOOL}-gcc $(FLAGS) $(GCC_FLAG) -S div64.c

.PHONY: clean gdb debug

debug: build_tests
	@echo "Ctrl-Q C for QEMU console, then quit to exit"
	$(MACHINE) -s -S -bios build/test_$(TEST_NAME)

gdb:
	gdb -ex 'target remote localhost:1234' ./build/test_$(TEST_NAME)

clean:
	rm -rf build/*

