#!make

#----------------------------------------
# Command line parameters

TEST_NAME ?= shell
OUTPUT_DEV ?= 5
MACHINE ?= virt

include platforms/$(MACHINE).mk

# The "terminal" test requires a specific output type.
ifeq ($(TEST_NAME), terminal)
OUTPUT_DEV = 5
else
OUTPUT_DEV = 3
endif

#----------------------------------------
# Build / compilation / execution flags

TOOL := riscv64-none-elf
# use im and -mabi=ilp32 if planning to not use reduced base integer extension
RISC_V_EXTENSIONS := emzicsr
FLAGS := -march=rv32$(RISC_V_EXTENSIONS) -mabi=ilp32e
AS_FLAGS := -I headers --defsym OUTPUT_DEV=$(OUTPUT_DEV) --defsym m_$(MACHINE)=1
GCC_FLAGS := -T platforms/$(MACHINE).ld -nostdlib -static -I headers

QEMU_EXTENSIONS := e=on,m=on,i=off,h=off,f=off,d=off,a=off,f=off,c=off,zawrs=off,sstc=off,zicntr=off,zihpm=off,zicboz=off,zicbom=off,svadu=off
QEMU := qemu-system-riscv32 -machine $(MACHINE) $(QEMU_MACHINE_CONFIG) -cpu rv32,$(QEMU_EXTENSIONS) -nographic -serial mon:stdio -echr 17

ifneq ($(filter debug, $(MAKECMDGOALS)),)
FLAGS += -g -o0
endif

ifneq ($(filter debug-main, $(MAKECMDGOALS)),)
FLAGS += -g -o0
endif

#----------------------------------------
# Project files

SRC := $(wildcard src/*.s)
# SRC_NO_MAIN := $(filter-out src/main.s, $(SRC))
OBJ_DIR := build/obj
OBJ := $(patsubst %.s, %.o, $(notdir $(SRC)))
OBJ_FILES := $(addprefix $(OBJ_DIR)/, $(OBJ))

DRIVERS_SRC := $(DRIVERS)
DRIVERS_OBJ := $(patsubst %.s, %.o, $(notdir $(DRIVERS_SRC)))
OBJ_FILES += $(addprefix $(OBJ_DIR)/, $(DRIVERS_OBJ))

TEST_ASM_SRC := $(wildcard tests/*.s)
TEST_ASM_OBJ := $(patsubst %.s, %.o, $(notdir $(TEST_ASM_SRC)))
TEST_ASM_OBJ_FILES := $(addprefix $(OBJ_DIR)/, $(TEST_ASM_OBJ))

TEST_C_SRC := $(wildcard tests/*.c)
TEST_C_OBJ := $(patsubst %.c, %.o, $(notdir $(TEST_C_SRC)))
TEST_C_OBJ_FILES := $(addprefix $(OBJ_DIR)/, $(TEST_C_OBJ))

TEST_FILES := $(patsubst %.o, %.elf, $(filter test_%.o, $(TEST_ASM_OBJ)))
TEST_FILES += $(patsubst %.o, %.elf, $(filter test_%.o, $(TEST_C_OBJ)))
TEST_SUPPORT_OBJ := $(OBJ_DIR)/assert.o $(OBJ_DIR)/helpers.o $(OBJ_DIR)/startup.o

#----------------------------------------

.PHONY: setup compile build compile_test build_tests build_all run test clean gdb debug

default: build_all

setup:
	mkdir -p build/obj

$(OBJ): %.o: src/%.s
	${TOOL}-as $(AS_FLAGS) $(FLAGS) -o $(OBJ_DIR)/$@ $<

$(DRIVERS_OBJ): %.o: src/drivers/%.s
	${TOOL}-as $(AS_FLAGS) $(FLAGS) -o $(OBJ_DIR)/$@ $<

compile: setup $(OBJ) $(DRIVERS_OBJ)

build: compile platforms/$(MACHINE).ld
	${TOOL}-gcc $(FLAGS) $(GCC_FLAGS) -o build/riscvos.elf $(OBJ_FILES)

$(TEST_ASM_OBJ): %.o: tests/%.s
	${TOOL}-as $(AS_FLAGS) $(FLAGS) -o $(OBJ_DIR)/$@ $<

$(TEST_C_OBJ): %.o: tests/%.c
	$(TOOL)-gcc $(FLAGS) $(GCC_FLAGS) -o $(OBJ_DIR)/$@ -c $<

compile_tests: setup $(TEST_ASM_OBJ) $(TEST_C_OBJ)

$(TEST_FILES): %.elf: $(OBJ_DIR)/%.o
	${TOOL}-gcc $(FLAGS) $(GCC_FLAGS) -o build/$@ $< $(filter-out $(OBJ_DIR)/main.o, $(OBJ_FILES)) $(TEST_SUPPORT_OBJ)

build_tests: compile compile_tests $(TEST_FILES)

build_all: build build_tests

run: build
	@echo "Ctrl-Q C for QEMU console, then quit to exit"
	$(QEMU) -bios build/riscvos.elf
	# qemu-system-riscv32 -nographic -serial pty -machine virt -bios build/riscvos
	# qemu-system-riscv32 -nographic -serial unix:/tmp/serial.socket,server -machine virt -bios build/riscvos

test: build_tests
	@echo "Ctrl-Q C for QEMU console, then quit to exit"
	$(QEMU) -bios build/test_$(TEST_NAME).elf

debug: build_tests
	@echo "Ctrl-Q C for QEMU console, then quit to exit"
	$(QEMU) -s -S -bios build/test_$(TEST_NAME).elf
	# $(QEMU) -s -S -bios build/riscvos.elf

debug-main: build
	@echo "Ctrl-Q C for QEMU console, then quit to exit"
	$(QEMU) -s -S -bios build/riscvos.elf

gdb:
	gdb -ex 'target remote localhost:1234' ./build/test_$(TEST_NAME).elf
	# gdb -ex 'target remote localhost:1234' ./build/riscvos.elf

gdb-main:
	gdb -ex 'target remote localhost:1234' ./build/riscvos.elf

clean:
	rm -rf build/*

