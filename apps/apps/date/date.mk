#!make

# This is a sub-make script
# Call it from repo's root falder as
# make build/hello-c.elf

ELF := date.elf

$(OUT):
	mkdir -p $(OUT)

$(OUT)/$(ELF): date.s
	$(CC) $(CFLAGS) -o $(OUT)/$(ELF) $(COMMON) date.s

.PHONY: clean

clean:
	rm -f $(OUT)/$(ELF)

