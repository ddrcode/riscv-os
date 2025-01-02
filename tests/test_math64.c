#include "types.h"
#include "test.h"
#include "uart.h"
#include "math64.h"


void test_add64(u32 xlo, u32 xhi, u32 ylo, u32 yhi) {
    u32 hi;
    u32 res;
    char str[32];
    u32 regs[6];

    res = add64(xlo, xhi, ylo, yhi);
    regarr(regs);
    // asm volatile (
    //     ""
    //     : "=r" (hi)
    // );
    puts("Testing add64: ");
    citoa(regs[0], str, 16);
    puts(str);
    puts("\n");
}

int test_main(int argc, char **argv) {
    // u32 a = udiv64(2,2,2,0);
    test_add64(0xffffffff, 0, 1, 0);
    return 0;
}

