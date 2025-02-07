#!make

#----------------------------------------
# Command line parameters

OUTPUT_DEV ?= 3
MACHINE ?= virt

# The "terminal" test requires a specific output type.
ifeq ($(TEST_NAME), terminal)
OUTPUT_DEV = 5
else
OUTPUT_DEV = 3
endif


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
CFLAGS := -march=$(ARCH) -mabi=$(ABI)  -nostdlib -static $(HEADERS) -T platforms/$(MACHINE).ld \
          -ffunction-sections -fdata-sections
LDFLAGS := -Arv32$(RISC_V_EXTENSIONS) -melf32lriscv -T platforms/$(MACHINE).ld -static -nostdlib

QEMU_EXTENSIONS := e=on,m=on,i=off,h=off,f=off,d=off,a=off,f=off,c=off,zawrs=off,sstc=off,zicntr=off,zihpm=off,zicboz=off,zicbom=off,svadu=off,zicsr=on,zfa=off,zmmul=off
QEMU := qemu-system-riscv32 -machine $(MACHINE) -bios none \
		-cpu rv32,pmp=true,$(QEMU_EXTENSIONS) -nographic -echr 17 \
        -serial mon:stdio -serial file:riscv-os.log


# Can be defined in machine-specific mk file (see platforms folder)
ifdef QEMU_MACHINE_CONFIG
    QEMU += $(QEMU_MACHINE_CONFIG)
endif

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
OBJDIR := $(BUILD)/obj
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

$(OBJDIR)/%.o: %.s $(OBJDIR)
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJDIR)/%.o: %.c $(OBJDIR)
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

gdb:
	gdb -ex 'target remote localhost:1234' $(BUILD)/$(ELF_NAME)

platforms/%.dts: %.dtb
	dtc -I dtb -O dts $< > $@

clean:
	rm -rf build

