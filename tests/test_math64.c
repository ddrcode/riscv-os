#include "types.h"
#include "assert.h"
#include "math64.h"
#include "bit64.h"

void test_uadd64(char* test_case, u32 xlo, u32 xhi, u32 ylo, u32 yhi, u32 rlo, u32 rhi) {
    U64 res;
    char str[32];
    res = uadd64(xlo, xhi, ylo, yhi);

    print_test_name("uadd64", test_case);

    u32 ex[] = { rlo, rhi };
    u32 val[] = { res.low, res.high };
    assert_arr(val, ex, 2);
}

void test_usub64(char* test_case, u32 xlo, u32 xhi, u32 ylo, u32 yhi, u32 rlo, u32 rhi) {
    U64 res;
    char str[32];
    res = usub64(xlo, xhi, ylo, yhi);

    print_test_name("usub64", test_case);

    u32 ex[] = { rlo, rhi };
    u32 val[] = { res.low, res.high };
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
    u32 ex[] = { rlo, rhi };
    u32 results[] = { res, regs[0] };
    assert_arr(results, ex, 2);
}

void test_ucmp64(char* test_case, u32 xlo, u32 xhi, u32 ylo, u32 yhi, i32 expected) {
    print_test_name("ucmp64", test_case);
    u32 res = ucmp64(xlo, xhi, ylo, yhi);
    assert_eq(res, expected);
}

void test_udiv64(char* test_case, u32 nlo, u32 nhi, u32 dlo, u32 dhi, u32 qlo, u32 qhi, u32 rlo, u32 rhi) {
    u32 regs[6];
    U64 res;
    res = udiv64(nlo, nhi, dlo, dhi);
    regarr(regs);
    print_test_name("udiv64", test_case);
    u32 ex[] = { qlo, qhi, rlo, rhi };
    u32 val[] = { res.low, res.high, regs[1], regs[2] };
    assert_arr(val, ex, 4);
}

int main(void) {
    eol();
    test_uadd64("~0, 0, 1, 0", ~0, 0, 1, 0, 0, 1);
    test_uadd64("256, 1024, 88, 156", 256, 1024, 88, 156, 344, 1180);
    eol();
    test_usub64("0, 1, 1, 0", 0, 1, 1, 0, 0xffffffff, 0);
    test_usub64("4096, 1, 1, 1,", 4096, 1, 1, 1, 4095, 0);
    test_usub64("0, 800, 0, 500,", 0, 800, 0, 500, 0, 300);
    eol();
    test_lshift64("1 << 31, 0, 1", 1 << 31, 0, 1, 0, 1);
    test_lshift64("~(1 << 31), ~0, 1", ~(1 << 31), ~0, 1, ~1, ~1);
    test_lshift64("0b11, 0b10, 1", 0b11, 0b10, 1, 0b110, 0b100);
    eol();
    test_getbit64("1, 0b11, 0", 1, 0b11, 0, 1);
    test_getbit64("0, 0b11, 32", 0, 0b11, 32, 1);
    test_getbit64("1, ~0, 31", 1, ~0, 31, 0);
    test_getbit64("~0, 0, 63", ~0, 0, 63, 0);
    eol();
    test_setbit64("1, 0b11, 34, 1", 1, 0b11, 34, 1, 1, 0b111);
    test_setbit64("1, 0b11, 0, 0", 1, 0b11, 0, 0, 0, 0b11);
    test_setbit64("1, 0b11, 32, 0", 1, 0b11, 32, 0, 1, 0b10);
    test_setbit64("0, 0, 31, 1", 0, 0, 31, 1, 1<<31, 0);
    test_setbit64("0, 0, 32, 1", 0, 0, 32, 1, 0, 1);
    eol();
    test_ucmp64("0, 1, 1, 0", 0, 1, 1, 0, 1);
    test_ucmp64("8, 0, 1, 0", 8, 0, 1, 0, 1);
    test_ucmp64("7, 5, 7, 5", 7, 5, 7, 5, 0);
    test_ucmp64("1, 1, 0, 3", 1, 1, 0, 3, -1);
    test_ucmp64("0, 1, 9, 1", 0, 1, 9, 1, -1);
    test_ucmp64("0, 800, 0, 500", 0, 800, 0, 500, 1);
    eol();
    test_udiv64("2, 16, 2, 0", 2, 16, 2, 0, 1, 8, 0, 0);
    test_udiv64("329, 0, 5, 0", 329, 0, 5, 0, 65, 0, 4, 0);
    test_udiv64("0, 800, 0, 500", 0, 800, 0, 500, 1, 0, 0, 300);
    test_udiv64("800, 0, 500, 0", 800, 0, 500, 0, 1, 0, 300, 0);

    print_summary();
    return 0;
}

