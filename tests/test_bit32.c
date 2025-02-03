#include "types.h"
#include "assert.h"
#include "bit32.h"

void test_bitlen32(char* test_case, u32 num, u32 exp) {
    print_test_name("bitlen32", test_case);
    u32 res = bitlen32(num);
    assert_eq(res, exp);
}

int main() {
    eol();
    test_bitlen32("0", 0, 0);
    test_bitlen32("1", 1, 1);
    test_bitlen32("3", 3, 2);
    test_bitlen32("0x100", 0x10000, 17);
    test_bitlen32("0x7fffffff", 0x7fffffff, 31);
    test_bitlen32("0x80000000", 0x80000000, 32);
    test_bitlen32("~0", ~0, 32);

    print_summary();
    return 0;
}
