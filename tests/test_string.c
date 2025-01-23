#include "assert.h"
#include "string.h"

void test_utoa(char* test_case, u32 number, i32 base, char* expected) {
    print_test_name("utoa", test_case);
    char str[33];
    utoa(number, str, base);
    assert_str(str, expected);
}

void test_itoa(char* test_case, i32 number, i32 base, char* expected) {
    print_test_name("itoa", test_case);
    char str[33];
    itoa(number, str, base);
    assert_str(str, expected);
}

void test_align_right(char* test_case, char* str, i32 len, char fill, char* expected) {
    print_test_name("align_right", test_case);
    str_align_right(str, len, fill);
    assert_str(str, expected);
}

int test_main() {
    eol();
    test_utoa("666, 10", 666, 10, "666");
    test_utoa("0x8000000, 16", 0x8000000, 16, "8000000");
    test_utoa("0xfeca00ee, 16", 0xfeca00ee, 16, "feca00ee");
    test_utoa("~0, 16", ~0, 16, "ffffffff");
    test_utoa("~0, 10", ~0, 10, "4294967295");
    test_utoa("0, 10", 0, 10, "0");
    eol();
    test_itoa("666, 10", 666, 10, "666");
    test_itoa("0x8000000, 16", 0x8000000, 16, "8000000");
    test_itoa("0xfeca00ee, 16", 0xfeca00ee, 16, "feca00ee");
    test_itoa("~0, 16", ~0, 16, "ffffffff");
    test_itoa("~0, 10", ~0, 10, "-1");
    test_itoa("-1, 10", -1, 10, "-1");
    test_itoa("0, 10", 0, 10, "0");
    test_itoa("19975493, 35", 19975493, 35, "david");
    eol();
    char str[10] = "515";
    test_align_right("\"515\", 10, '0'", str, 10, '0', "000000515");
    strcpy(str, "123456789");
    test_align_right("\"123456789\", 10, '.'", str, 10, '0', "123456789");
    print_summary();
    return 0;
}
