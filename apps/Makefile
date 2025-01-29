#!make

TOOL := riscv64-none-elf

AS := $(TOOL)-as
CC := $(TOOL)-cc
LD := $(TOOL)-ld

export ROOT := ../..

RISC_V_EXTENSIONS := emzicsr
ARCH := rv32$(RISC_V_EXTENSIONS)
ABI := ilp32e
export ASFLAGS := -march=$(ARCH) -mabi=$(ABI) -I headers --defsym OUTPUT_DEV=2 --defsym m_$(MACHINE)=1
export CFLAGS := -march=$(ARCH) -mabi=$(ABI)  -nostdlib -static -I $(ROOT)/headers -T $(ROOT)/platforms/virt.ld

CARGO_FLAGS := -Zbuild-std=core --target ./riscv32im-unknown-none-elf.json --release

ifneq ($(filter release, $(MAKECMDGOALS)),)
CFLAGS += -Os
LDFLAGS += --gc-sections
else
ASFLAGS += -g
CFLAGS += -g -O0
LDFLAGS += -g --no-gc-sections
endif

VPATH := common
OUT := build
RELEASE = $(OUT)/release

export COMMON := $(ROOT)/$(OUT)/common.o

MAKE := OUT=$(ROOT)/$(OUT) make --warn-undefined-variables --no-print-directory

APPS := hello-asm hello-c date ls fbdump
APP_TARGETS := $(addsuffix .elf, $(addprefix $(OUT)/, $(APPS)))
APP_RELEASES := $(addprefix $(RELEASE)/, $(APPS))


#----------------------------------------


default: build-all

$(OUT):
	mkdir -p $(OUT)

$(RELEASE):
	mkdir -p $(RELEASE)

$(OUT)/common.o: $(OUT) lib/*.s common/*.s
	$(AS) $(ASFLAGS) -o $(OUT)/common.o common/*.s lib/*.s

$(OUT)/%.elf: apps/%/* $(OUT)/common.o
	$(MAKE) -C ./apps/$(patsubst %.elf,%,$(@F)) -f $(patsubst %.elf,%,$(@F)).mk $(ROOT)/$@

build-rust: $(OUT)
	cargo build -Zbuild-std=core --target platforms/riscv32im-unknown-none-elf.json --release
	cp target/riscv32im-unknown-none-elf/release/hello-rust $(OUT)/hello-rust.elf

build-all: $(APP_TARGETS) build-rust

$(RELEASE)/%: $(OUT)/%.elf | $(RELEASE)
	$(TOOL)-strip --strip-all $<
	$(TOOL)-objcopy -O binary $< $@

release-all: $(APP_RELEASES)

disc: release-all
	rm -f disc.tar
	touch $(OUT)/release/.system
	ls -A $(OUT)/release | xargs tar -cvf disc.tar -C $(OUT)/release
	truncate -c -s 32M disc.tar

clean:
	@for app in $(APPS); do \
		$(MAKE) -C ./apps/$$app -f $$app.mk clean ;\
	done
	cargo clean
	rm -rf $(OUT)

.PHONY: clean disc build-all build-rust


