#include "types.h"
#include "time.h"
#include "assert.h"
#include "string.h"

u32 time_to_u32(u32 hr, u32 min, u32 sec) {
    return (hr << 16) | (min << 8) | sec;
}

u32 date_to_u32(u32 year, u32 month, u32 day, u32 dow) {
    return ((dow-1) << 24) | ((year-1900) << 16) | ((month-1) << 8) | (day);
}

void test_get_time(u32 secs, u32 expected) {
    char str[33];
    itoa(secs, str, 10);
    print_test_name("get_time", str);

    u32 time = get_time(secs);
    char time_str[16];
    time_to_str(time, time_str);

    print(" [");
    print(time_str);
    print("] ");

    assert_eq(time, expected);
}

void test_get_date(u32 secs, u32 expected) {
    char str[33];
    itoa(secs, str, 10);
    print_test_name("get_date", str);

    u32 date = get_date(secs);
    char date_str[16];
    date_to_str(date, date_str);

    print(" [");
    print(date_str);
    print("] ");

    assert_eq(date, expected);
}

int test_main(void) {

    u32 test_data[][3] = {
        { 1736026615, time_to_u32(21, 36, 55), date_to_u32(2025, 1, 4, 6) },
        { 0, time_to_u32(0, 0, 0), date_to_u32(1970, 1, 1, 4) },
        { 946684799, time_to_u32(23, 59, 59), date_to_u32(1999, 12, 31, 5) },
        { 230959800, time_to_u32(3, 30, 00), date_to_u32(1977, 04, 27, 3) },
        { 4294967295, time_to_u32(6, 28, 15), date_to_u32(2106, 02, 07, 7) },
    };
    u32 len = sizeof(test_data) / sizeof(test_data[0]);

    eol();
    for(int i=0; i<len; ++i) {
        test_get_time(test_data[i][0], test_data[i][1]);
    }
    eol();
    for(int i=0; i<len; ++i) {
        test_get_date(test_data[i][0], test_data[i][2]);
    }
    print_summary();
    return 0;
}
