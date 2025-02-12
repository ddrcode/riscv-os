#!make

# Tetris game makefile
# Call it from repo's root folder as
# make build/tetris.elf

ELF := tetris.elf
SRC := tetris.c

$(OUT):
	mkdir -p $(OUT)

$(OUT)/$(ELF): $(SRC)
	$(CC) $(CFLAGS) -o $(OUT)/$(ELF) $(COMMON) $(SRC)

.PHONY: clean

clean:
	rm -f $(OUT)/$(ELF)
