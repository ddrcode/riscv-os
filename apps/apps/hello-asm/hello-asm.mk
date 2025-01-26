#!make

# This is a sub-make script
# Call it from repo's root falder as
# make build/hello-c.elf

ELF := hello-asm.elf

$(OUT):
	mkdir -p $(OUT)

$(OUT)/$(ELF): hello.s
	$(CC) $(CFLAGS) -o $(OUT)/$(ELF) $(COMMON) hello.s

.PHONY: clean

clean:
	rm -f $(OUT)/$(ELF)

