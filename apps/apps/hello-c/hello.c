#include "types.h"
#include "system.h"
#include "io.h"

int main() {
    char* msg = "Running C program";
    // syscall((u32)msg, 0, 0, 0, 0, 22);
    prints(msg);
    return 0;
}
