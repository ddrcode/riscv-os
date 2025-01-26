#!make

# This is a sub-make script
# Call it from repo's root falder as
# make build/fbdump.elf

FILE := fbdump
ELF := $(FILE).elf

$(OUT):
	mkdir -p $(OUT)

$(OUT)/$(ELF): $(FILE).s
	$(CC) $(CFLAGS) -o $(OUT)/$(ELF) $(COMMON) $(FILE).s

.PHONY: clean

clean:
	rm -f $(OUT)/$(ELF)


