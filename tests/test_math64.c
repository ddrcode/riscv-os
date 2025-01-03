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

void test_lshift64(char* test_case, u32 xlo, u32 xhi, int bits, u32 rlo, u32 rhi) {
    u32 res, regs[6];
    res = lshift64(xlo, xhi, bits);
    regarr(regs);
    print_test_name("lshift64", test_case);
    u32 ex[] = { rlo, rhi };
    u32 val[] = { res, regs[0] };
    assert_arr(val, ex, 2);
}

void test_getbit64(char* test_case, u32 xlo, u32 xhi, i32 bitno, i32 expected) {
    print_test_name("getbit64", test_case);
    u32 res = getbit64(xlo, xhi, bitno);
    assert_eq(res, expected);
}

void test_setbit64(char* test_case, u32 xlo, u32 xhi, i32 bit, u32 val, u32 rlo, u32 rhi) {
    u32 res, regs[6];
    res = setbit64(xlo, xhi, bit, val);
    regarr(regs);
    print_test_name("setbit64", test_case);
    u32 ex[] = { xlo, xhi };
    u32 results[] = { res, regs[0] };
    assert_arr(results, ex, 2);
}

void test_udiv64(char* test_case, u32 nlo, u32 nhi, u32 dlo, u32 dhi, u32 qlo, u32 qhi, u32 rlo, u32 rhi) {
    u32 res, regs[6];
    res = udiv64(nlo, nhi, dlo, dhi);
    regarr(regs);
    print_test_name("udiv64", test_case);
    u32 ex[] = { qlo, qhi, rlo, rhi };
    u32 val[] = { res, regs[0], regs[1], regs[2] };
    assert_arr(val, ex, 4);
}

int test_main(int argc, char **argv) {
    test_uadd64("lo(~0) hi(0) + lo(1) hi(0)", ~0, 0, 1, 0, 0, 1);
    test_uadd64("lo(256) hi(1024) + lo(88) hi(156)", 256, 1024, 88, 156, 344, 1180);

    test_usub64("lo(0) hi(1) - lo(1) hi(0)", 0, 1, 1, 0, 0xffffffff, 0);
    test_usub64("lo(4096) hi(1) - lo(1) hi(1)", 0, 1, 1, 0, 0xffffffff, 0);

    test_lshift64("(1 << 31) << 1", 1 << 31, 0, 1, 0, 1);
    test_lshift64("shift with no carry", 0b11, 0b10, 1, 0b110, 0b100);

    test_getbit64("1, 0b11, 0", 1, 0b11, 0, 1);
    test_getbit64("0, 0b11, 32", 0, 0b11, 32, 1);

    test_setbit64("1, 0b11, 34, 1", 1, 0b11, 34, 1, 1, 0b111);
    test_setbit64("1, 0b11, 0, 0", 1, 0b11, 0, 0, 0, 0b11);

    test_udiv64("2, 16, 2, 0", 2, 16, 2, 0, 1, 8, 0, 0);

    return 0;
}

