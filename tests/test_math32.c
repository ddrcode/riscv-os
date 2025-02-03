#include "types.h"
#include "assert.h"
#include "math32.h"

void test_udiv32(char* test_case, u32 x, u32 y, u32 q) {
    print_test_name("udiv32", test_case);
    u32 res = udiv32(x, y);
    assert_eq(res, q);
}

void test_urem32(char* test_case, u32 x, u32 y, u32 q) {
    print_test_name("urem32", test_case);
    u32 res = urem32(x, y);
    assert_eq(res, q);
}

void test_div32(char* test_case, i32 x, i32 y, i32 q) {
    print_test_name("div32", test_case);
    i32 res = div32(x, y);
    assert_eq_signed(res, q);
}

void test_rem32(char* test_case, i32 x, i32 y, i32 q) {
    print_test_name("rem32", test_case);
    i32 res = rem32(x, y);
    assert_eq_signed(res, q);
}

int main() {
    eol();
    test_udiv32("16/8", 16, 8, 2);
    test_udiv32("333/9", 333, 9, 37);
    test_udiv32("1/18", 1, 18, 0);
    test_udiv32("~0/16", ~0, 16, 0xfffffff);
    test_udiv32("0/1", 0, 1, 0);
    test_udiv32("3/0", 3, 0, ~0);
    eol();
    test_urem32("16/8", 16, 8, 0);
    test_urem32("333/125", 333, 125, 83);
    test_urem32("1/18", 1, 18, 1);
    eol();
    test_div32("-27/3", -27, 3, -9);
    test_div32("-127/-11", -127, -11, 11);
    test_div32("9/-30", 9, -30, 0);
    eol();
    test_rem32("-28/3", -28, 3, -1);
    test_rem32("-127/-11", -127, -11, -6);
    test_rem32("9/-30", 9, -30, 9);
    print_summary();
    return 0;
}
