#!make

# Snake game makefile
# Call it from repo's root folder as
# make build/snake.elf

ELF := snake.elf
SRC := snake.c

$(OUT):
	mkdir -p $(OUT)

$(OUT)/$(ELF): $(SRC)
	$(CC) $(CFLAGS) -o $(OUT)/$(ELF) $(COMMON) $(SRC)

.PHONY: clean

clean:
	rm -f $(OUT)/$(ELF)
