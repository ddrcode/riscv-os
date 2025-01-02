#include "types.h"
#include "assert.h"
#include "math64.h"


void test_uadd64(char* test_case, u32 xlo, u32 xhi, u32 ylo, u32 yhi, u32 rlo, u32 rhi) {
    u32 hi, res, regs[6];
    char str[32];
    res = uadd64(xlo, xhi, ylo, yhi);
    regarr(regs);

    print_test_name("uadd64", test_case);

    u32 ex[] = { rlo, rhi };
    u32 val[] = { res, regs[0] };
    assert_arr(val, ex, 2);
}

void test_usub64(char* test_case, u32 xlo, u32 xhi, u32 ylo, u32 yhi, u32 rlo, u32 rhi) {
    u32 hi, res, regs[6];
    char str[32];
    res = usub64(xlo, xhi, ylo, yhi);
    regarr(regs);

    print_test_name("usub64", test_case);

    u32 ex[] = { rlo, rhi };
    u32 val[] = { res, regs[0] };
    assert_arr(val, ex, 2);
}

int test_main(int argc, char **argv) {
    test_uadd64("lo(~0) hi(0) + lo(1) hi(0)", ~0, 0, 1, 0, 0, 1);
    test_uadd64("lo(256) hi(1024) + lo(88) hi(156)", 256, 1024, 88, 156, 344, 1180);

    test_usub64("lo(0) hi(1) - lo(1) hi(0)", 0, 1, 1, 0, 0xffffffff, 0);
    test_usub64("lo(4096) hi(1) - lo(1) hi(1)", 0, 1, 1, 0, 0xffffffff, 0);
    return 0;
}
