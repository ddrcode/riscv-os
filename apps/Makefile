#!make

MACHINE=virt


TOOL := riscv64-none-elf

AS := $(TOOL)-as
CC := $(TOOL)-cc
LD := $(TOOL)-ld

export ROOT := ../..

RISC_V_EXTENSIONS := emzicsr
ARCH := rv32$(RISC_V_EXTENSIONS)
ABI := ilp32e
HEADERS := -I ../headers
export ASFLAGS := -march=$(ARCH) -mabi=$(ABI) $(HEADERS) --defsym OUTPUT_DEV=2 --defsym m_$(MACHINE)=1
export CFLAGS := -march=$(ARCH) -mabi=$(ABI)  -nostdlib -static \
                 -I $(ROOT)/../headers -T $(ROOT)/platforms/virt.ld \
                 -ffunction-sections -fdata-sections -flto
export LDFLAGS := -nostdlib -static

CARGO_FLAGS := -Zbuild-std=core --target ./riscv32im-unknown-none-elf.json --release

# ifneq ($(filter release, $(MAKECMDGOALS)),)
    # CFLAGS += -Os -Wl,--gc-sections
    CFLAGS += -Wl,--gc-sections
    # LDFLAGS += --gc-sections
# else
    # ASFLAGS += -g
    # CFLAGS += -g -O0
    # LDFLAGS += -g --no-gc-sections
# endif

VPATH := common
OUT := build
RELEASE = $(OUT)/release
DEBUG = $(OUT)/debug

export COMMON := $(ROOT)/$(OUT)/common.o

MAKE := OUT=$(ROOT)/$(OUT) make --warn-undefined-variables --no-print-directory

APPS := hello-asm hello-c date ls fbdump snake tetris
APP_TARGETS := $(addsuffix .elf, $(addprefix $(OUT)/, $(APPS)))
APP_RELEASES := $(addprefix $(RELEASE)/, $(APPS))
APP_DEBUGS := $(addprefix $(DEBUG)/, $(APPS))

RUST_APPS := hello-rust clock


#----------------------------------------


default: build-all

$(OUT):
	mkdir -p $(OUT)

$(RELEASE):
	mkdir -p $(RELEASE)

$(DEBUG):
	mkdir -p $(DEBUG)

$(OUT)/common.o: $(OUT) ../lib/*.s common/*.s
	$(AS) $(ASFLAGS) -o $(OUT)/common.o common/*.s ../lib/*.s

$(OUT)/libcommon.a: $(OUT)/common.o
	$(TOOL)-ar -rcs $@ $<

common/riscvos-lib-rust/src/bindings.rs: ../headers/bindings.h $(OUT)
	bindgen $< -o $@ --ctypes-prefix=cty --use-core

$(OUT)/%.elf: apps/%/* $(OUT)/common.o
	$(MAKE) -C ./apps/$(patsubst %.elf,%,$(@F)) -f $(patsubst %.elf,%,$(@F)).mk $(ROOT)/$@

build-rust: $(OUT)/libcommon.a common/riscvos-lib-rust/src/bindings.rs
	OUT=$(OUT) cargo build -Zbuild-std=core --target platforms/riscv32im-unknown-none-elf.json --release

build-all: $(APP_TARGETS) build-rust

$(RELEASE)/%: $(OUT)/%.elf | $(RELEASE)
	$(TOOL)-strip --strip-all $<
	$(TOOL)-objcopy -O binary $< $@

release-rust: build-rust $(RELEASE)
	@for app in $(RUST_APPS); do \
		cp target/riscv32im-unknown-none-elf/release/$$app $(OUT)/$$app.elf; \
		$(TOOL)-strip --strip-all $(OUT)/$$app.elf; \
		$(TOOL)-objcopy -O binary $(OUT)/$$app.elf $(RELEASE)/$$app; \
	done

release-all: $(APP_RELEASES) release-rust

$(DEBUG)/%: $(OUT)/%.elf | $(DEBUG)
	cp $< $@

debug-all: $(APP_DEBUGS)

disc: release-all
	rm -f disc.tar
	touch $(OUT)/release/.system
	ls -A $(OUT)/release | xargs tar -cvf disc.tar -C $(OUT)/release
	truncate -c -s 32M disc.tar

debug-disc: debug-all
	rm -f debug-disc.tar
	touch $(DEBUG)/.system
	ls -A $(DEBUG) | xargs tar -cvf debug-disc.tar -C $(DEBUG)
	truncate -c -s 32M debug-disc.tar

clean:
	@for app in $(APPS); do \
		$(MAKE) -C ./apps/$$app -f $$app.mk clean ;\
	done
	cargo clean
	rm -rf $(OUT)

.PHONY: clean disc build-all build-rust
