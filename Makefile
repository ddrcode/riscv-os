#!make

#----------------------------------------
# Command line parameters

MACHINE ?= virt

# Output device(s), see README. Tests print plain text to the serial console,
# except the "terminal" test which exercises the terminal emulation.
ifndef TEST_NAME
OUTPUT_DEV ?= 5
else ifeq ($(TEST_NAME), terminal)
OUTPUT_DEV ?= 5
else
OUTPUT_DEV ?= 3
endif

# Self-terminating tests, run by `make test` (the remaining ones are interactive)
TESTS ?= bit32 buffer math32 math64 rtc string syscall time irq
TEST_TIMEOUT ?= 10


#----------------------------------------
# Include machine-specific configuration

include platforms/$(MACHINE).mk


#----------------------------------------
# Build / compilation / execution flags

TOOL := riscv64-none-elf
AS := $(TOOL)-as
CC := $(TOOL)-cc
LD := $(TOOL)-ld

# use im and -mabi=ilp32 if planning to not use reduced base integer extension

RISC_V_EXTENSIONS := em_zicsr
ARCH := rv32$(RISC_V_EXTENSIONS)
ABI := ilp32e
HEADERS := -I headers
ASFLAGS := -march=$(ARCH) -mabi=$(ABI) $(HEADERS) --defsym OUTPUT_DEV=$(OUTPUT_DEV) --defsym m_$(MACHINE)=1
# A single RWX segment is fine for a bare-metal image, silence the linker's warning about it
CFLAGS := -march=$(ARCH) -mabi=$(ABI)  -nostdlib -static $(HEADERS) -T platforms/$(MACHINE).ld \
          -ffunction-sections -fdata-sections -Wl,--no-warn-rwx-segments
LDFLAGS := -Arv32$(RISC_V_EXTENSIONS) -melf32lriscv -T platforms/$(MACHINE).ld -static -nostdlib \
           --no-warn-rwx-segments

QEMU_EXTENSIONS := e=on,m=on,i=off,h=off,f=off,d=off,a=off,f=off,c=off,zawrs=off,sstc=off,zicntr=off,zihpm=off,zicboz=off,zicbom=off,svadu=off,zicsr=on,zfa=off,zmmul=off
QEMU_CMD := qemu-system-riscv32 -machine $(MACHINE) -bios none \
            -cpu rv32,pmp=true,$(QEMU_EXTENSIONS) -nographic $(QEMU_MACHINE_CONFIG)

# Interactive run: serial console on the terminal, QEMU monitor on Ctrl-Q
QEMU := $(QEMU_CMD) -echr 17 -serial mon:stdio -serial file:riscv-os.log

# Non-interactive run used by the tests
QEMU_TEST := $(QEMU_CMD) -serial stdio -monitor none

ifneq ($(filter release, $(MAKECMDGOALS)),)
    CFLAGS += -Os -Wl,--gc-sections
    LDFLAGS += --gc-sections
else
    ASFLAGS += -g
    CFLAGS += -g -O0
    LDFLAGS += -g --no-gc-sections
endif

ifdef TEST_NAME
    ELF_NAME = test_$(TEST_NAME).elf
else
    ELF_NAME = $(MACHINE).elf
endif


#----------------------------------------
# Project files

VPATH = src src/drivers src/platforms src/hal tests lib

SRC := $(wildcard src/*.s)
SRC += $(wildcard src/hal/*.s)
SRC += $(wildcard lib/*.s)
SRC += $(DRIVERS)
SRC += src/platforms/$(MACHINE).s

BUILD := build
# Objects depend on the machine and the output device (assembler symbols),
# so each combination gets its own directory
OBJDIR := $(BUILD)/obj-$(MACHINE)-$(OUTPUT_DEV)
OBJ := $(patsubst %.s, %.o, $(notdir $(SRC)))
OBJ_FILES := $(addprefix $(OBJDIR)/, $(OBJ))

TEST_ASM_SRC := $(wildcard tests/*.s)
TEST_ASM_OBJ := $(patsubst %.s, $(OBJDIR)/%.o, $(notdir $(TEST_ASM_SRC)))

TEST_C_SRC := $(wildcard tests/*.c)
TEST_C_OBJ := $(patsubst %.c, $(OBJDIR)/%.o, $(notdir $(TEST_C_SRC)))

TEST_SUPPORT_OBJ := $(OBJDIR)/assert.o $(OBJDIR)/helpers.o

TEST_OBJ_FILES := $(filter-out $(OBJDIR)/main.o, $(OBJ_FILES))
TEST_OBJ_FILES += $(OBJDIR)/test_$(TEST_NAME).o

#----------------------------------------

.PHONY: compile build compile-tests build-test build-tests build-all run test clean gdb debug

default: $(BUILD)/$(MACHINE).bin

$(BUILD):
	mkdir -p $(BUILD)

$(OBJDIR):
	mkdir -p $(OBJDIR)

$(OBJDIR)/%.o: %.s | $(OBJDIR)
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJDIR)/%.o: %.c | $(OBJDIR)
	$(CC) $(CFLAGS) -o $@ -c $<

compile: $(OBJ_FILES)

compile-tests: $(TEST_ASM_OBJ) $(TEST_C_OBJ)

$(BUILD)/test_%.elf: platforms/$(MACHINE).ld $(TEST_SUPPORT_OBJ) $(TEST_OBJ_FILES)
	$(CC) $(CFLAGS) -o $@ $(TEST_SUPPORT_OBJ) $(TEST_OBJ_FILES)

$(BUILD)/%.elf: platforms/%.ld $(OBJ_FILES)
	$(CC) $(CFLAGS) -o $@ $(OBJ_FILES)

$(BUILD)/%.bin: platforms/%.ld $(OBJ_FILES)
	$(LD) $(LDFLAGS) -o $@ $(OBJ_FILES)
	$(TOOL)-strip --strip-all $@
	$(TOOL)-objcopy -O binary $@ $@

run: $(BUILD)/$(ELF_NAME)
	@echo "Ctrl-Q C for QEMU console, then quit to exit"
	$(QEMU) -kernel $<

debug: $(BUILD)/$(ELF_NAME)
	@echo "Ctrl-Q C for QEMU console, then quit to exit"
	$(QEMU) -s -S -kernel $<

release: clean $(BUILD)/$(MACHINE).bin

# Builds and runs every test from $(TESTS) in QEMU; fails on the first failing test.
# Run a subset with `make test TESTS="math64 string"`.
test:
	@for t in $(TESTS); do \
	    $(MAKE) -s TEST_NAME=$$t $(BUILD)/test_$$t.elf || exit 1; \
	    echo "=== $$t ==="; \
	    TIMEOUT=$(TEST_TIMEOUT) tests/run.sh $(BUILD)/test_$$t.elf $(QEMU_TEST) || exit 1; \
	done
	@echo "All tests passed: $(TESTS)"

gdb:
	gdb -ex 'target remote localhost:1234' $(BUILD)/$(ELF_NAME)

platforms/%.dts: %.dtb
	dtc -I dtb -O dts $< > $@

clean:
	rm -rf build

