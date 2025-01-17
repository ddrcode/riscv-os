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
AS := $(TOOL)-as
CC := $(TOOL)-cc
LD := $(TOOL)-ld

# use im and -mabi=ilp32 if planning to not use reduced base integer extension
RISC_V_EXTENSIONS := emzicsr
ARCH := rv32$(RISC_V_EXTENSIONS)
ABI := ilp32e
ASFLAGS := -march=$(ARCH) -mabi=$(ABI) -I headers --defsym OUTPUT_DEV=$(OUTPUT_DEV) --defsym m_$(MACHINE)=1
CFLAGS := -march=$(ARCH) -mabi=$(ABI)  -nostdlib -static -I headers -T platforms/$(MACHINE).ld
LDFLAGS := -Arv32$(RISC_V_EXTENSIONS) -melf32lriscv -T platforms/$(MACHINE).ld -static -nostdlib

QEMU_EXTENSIONS := e=on,m=on,i=off,h=off,f=off,d=off,a=off,f=off,c=off,zawrs=off,sstc=off,zicntr=off,zihpm=off,zicboz=off,zicbom=off,svadu=off,zicsr=on,zfa=off,zmmul=on
QEMU := qemu-system-riscv32 -machine $(MACHINE) $(QEMU_MACHINE_CONFIG) -cpu rv32,$(QEMU_EXTENSIONS) -nographic -serial mon:stdio -echr 17

ifneq ($(filter release, $(MAKECMDGOALS)),)
CFLAGS += -Os
LDFLAGS += --gc-sections
else
ASFLAGS += -g
CFLAGS += -g -O0
LDFLAGS += -g --no-gc-sections
endif

#----------------------------------------
# Project files

VPATH = src src/drivers src/platforms tests

SRC := $(wildcard src/*.s)
SRC += $(DRIVERS)
SRC += src/platforms/$(MACHINE).s

OBJDIR := build/obj
OBJ := $(patsubst %.s, %.o, $(notdir $(SRC)))
OBJ_FILES := $(addprefix $(OBJDIR)/, $(OBJ))

TEST_ASM_SRC := $(wildcard tests/*.s)
TEST_ASM_OBJ := $(patsubst %.s, %.o, $(notdir $(TEST_ASM_SRC)))

TEST_C_SRC := $(wildcard tests/*.c)
TEST_C_OBJ := $(patsubst %.c, %.o, $(notdir $(TEST_C_SRC)))

TEST_FILES := $(patsubst %.o, %.elf, $(filter test_%.o, $(TEST_ASM_OBJ)))
TEST_FILES += $(patsubst %.o, %.elf, $(filter test_%.o, $(TEST_C_OBJ)))
TEST_SUPPORT_OBJ := $(OBJDIR)/assert.o $(OBJDIR)/helpers.o $(OBJDIR)/startup.o

#----------------------------------------

.PHONY: compile build compile-test build-test build-tests build-all run test clean gdb debug

default: build-all

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(OBJDIR)/$(OBJ): %.o: %.s | $(OBJDIR)
	$(AS) $(ASFLAGS) -o $(OBJDIR)/$@ $<

compile: $(OBJ)

build: compile platforms/$(MACHINE).ld
	$(CC) $(CFLAGS) -o build/$(MACHINE).elf $(OBJ_FILES)

release: compile platforms/$(MACHINE).ld
	$(LD) $(LDFLAGS) -o build/$(MACHINE).elf $(OBJ_FILES)
	$(TOOL)-strip --strip-all build/$(MACHINE).elf

$(OBJDIR)/$(TEST_ASM_OBJ): %.o: %.s | $(OBJDIR)
	$(AS) $(ASFLAGS) -o $(OBJDIR)/$@ $<

$(OBJDIR)/$(TEST_C_OBJ): %.o: %.c | $(OBJDIR)
	$(CC) $(CFLAGS) -o $(OBJDIR)/$@ -c $<

compile-tests: $(TEST_ASM_OBJ) $(TEST_C_OBJ)

$(TEST_FILES): %.elf: $(OBJDIR)/%.o
	$(CC) $(CFLAGS) -o build/$@ $< $(filter-out $(OBJDIR)/main.o, $(OBJ_FILES)) $(TEST_SUPPORT_OBJ)

build-test: compile compile-tests test_$(TEST_NAME).elf

build-tests: compile compile-tests $(TEST_FILES)

build-all: build build-tests

run: build
	@echo "Ctrl-Q C for QEMU console, then quit to exit"
	$(QEMU) -bios build/$(MACHINE).elf

test: build-test
	@echo "Ctrl-Q C for QEMU console, then quit to exit"
	$(QEMU) -bios build/test_$(TEST_NAME).elf

debug: build-test
	@echo "Ctrl-Q C for QEMU console, then quit to exit"
	$(QEMU) -s -S -bios build/test_$(TEST_NAME).elf

debug-main: build
	@echo "Ctrl-Q C for QEMU console, then quit to exit"
	$(QEMU) -s -S -bios build/$(MACHINE).elf

gdb: build-test
	gdb -ex 'target remote localhost:1234' ./build/test_$(TEST_NAME).elf

gdb-main:
	gdb -ex 'target remote localhost:1234' ./build/$(MACHINE).elf

clean:
	rm -rf build/*

