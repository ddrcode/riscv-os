#!make

# This is a sub-make script
# Call it from repo's root falder as
# make build/hello-c.elf

ELF := ls.elf

$(OUT):
	mkdir -p $(OUT)

$(OUT)/$(ELF): ls.s
	$(CC) $(CFLAGS) -o $(OUT)/$(ELF) $(COMMON) ls.s

.PHONY: clean

clean:
	rm -f $(OUT)/$(ELF)

