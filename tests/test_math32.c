#include "types.h"
#include "assert.h"
#include "math32.h"

void test_udiv32(char* test_case, u32 x, u32 y, u32 q) {
    print_test_name("udiv32", test_case);
    u32 res = udiv32(x, y);
    assert_eq(res, q);
}

int test_main() {
    eol();
    test_udiv32("16/8", 16, 8, 2);
    test_udiv32("333/9", 333, 9, 37);
    test_udiv32("1/18", 1, 18, 0);
    print_summary();
    return 0;
}
