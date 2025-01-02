#include "types.h"
#include "test.h"
#include "math64.h"


void test_add64(char* test_case, u32 xlo, u32 xhi, u32 ylo, u32 yhi, u32 rlo, u32 rhi) {
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
    print("Testing add64 (");
    print(test_case);
    print("): ");

    u32 ex[] = { rlo, rhi };
    u32 val[] = { res, regs[0] };
    assert_arr(val, ex, 2);
}

int test_main(int argc, char **argv) {
    // u32 a = udiv64(2,2,2,0);
    test_add64("lo(~0) hi(0) + lo(1) hi(0)", ~0, 0, 1, 0, 0, 1);
    test_add64("lo(256) hi(1024) + lo(88) hi(156)", 256, 1024, 88, 156, 344, 1180);
    return 0;
}

