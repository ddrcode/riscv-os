#include "types.h"
#include "time.h"
#include "assert.h"

u32 time_to_u32(u32 hr, u32 min, u32 sec) {
    return (hr << 16) | (min << 8) | sec;
}

u32 date_to_u32(u32 year, u32 month, u32 day, u32 dow) {
    return ((dow-1) << 24) | ((year-1900) << 16) | (month << 8) | day;
}
void test_get_time(u32 secs, u32 expected) {
    char str[33];
    itoa(secs, str, 10);
    print_test_name("get_time", str);

    u32 time = get_time(secs);
    assert_eq(time, expected);
}

void test_get_date(u32 secs, u32 expected) {
    char str[33];
    itoa(secs, str, 10);
    print_test_name("get_date", str);

    u32 time = get_date(secs);
    assert_eq(time, expected);
}

int test_main(void) {
    test_get_time(1736026615, time_to_u32(21, 36, 55));    // 2025-01-04

    test_get_date(1736026615, date_to_u32(2025, 1, 4, 6));    // 2025-01-04
    print_summary();
    return 0;
}
