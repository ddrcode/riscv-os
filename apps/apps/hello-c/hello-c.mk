#!make

# This is a sub-make script
# Call it from repo's root falder as
# make build/hello-c.elf

ELF := hello-c.elf

$(OUT):
	mkdir -p $(OUT)

$(OUT)/$(ELF): hello.c
	$(CC) $(CFLAGS) -Os -flto -ffunction-sections -fdata-sections -o $(OUT)/$(ELF) $(COMMON) hello.c

.PHONY: clean

clean:
	rm -f $(OUT)/$(ELF)

