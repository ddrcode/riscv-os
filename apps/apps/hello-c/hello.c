#include "types.h"
#include "system.h"
#include "io.h"

int main(int argc, char* argv[]) {
    char* msg = "Running C program";
    prints("Hello, ");
    println(argc > 1 ? argv[1] : "RISCV-OS");
    return 0;
}
