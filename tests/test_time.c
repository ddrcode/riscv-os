#include "types.h"
#include "time.h"
#include "assert.h"
#include "string.h"

// Helpers taking human-readable values: 1-based month, day-of-week with Monday = 1
// (the Time/Date structures use 0-based month and dow, and year - 1900)

Time mk_time(u32 hr, u32 min, u32 sec) {
    Time time = { .seconds = sec, .minutes = min, .hours = hr };
    return time;
}

Date mk_date(u32 year, u32 month, u32 day, u32 dow) {
    Date date = { .day = day, .month = month - 1, .year = year - 1900, .dow = dow - 1 };
    return date;
}

void test_get_time(u32 secs, Time expected) {
    char str[33];
    utoa(secs, str, 10);
    print_test_name("get_time", str);

    Time time = get_time(secs);
    char time_str[16];
    time_to_str(time, time_str);

    print(" [");
    print(time_str);
    print("] ");

    u32 val[] = { time.hours, time.minutes, time.seconds };
    u32 ex[] = { expected.hours, expected.minutes, expected.seconds };
    assert_arr(val, ex, 3);
}

void test_get_date(u32 secs, Date expected) {
    char str[33];
    utoa(secs, str, 10);
    print_test_name("get_date", str);

    Date date = get_date(secs);
    char date_str[16];
    date_to_str(date, date_str);

    print(" [");
    print(date_str);
    print("] ");

    u32 val[] = { date.year, date.month, date.day, date.dow };
    u32 ex[] = { expected.year, expected.month, expected.day, expected.dow };
    assert_arr(val, ex, 4);
}

typedef struct {
    u32 secs;
    Time time;
    Date date;
} TestCase;

int main(void) {

    TestCase test_data[] = {
        { 1736026615, mk_time(21, 36, 55), mk_date(2025, 1, 4, 6) },
        { 0, mk_time(0, 0, 0), mk_date(1970, 1, 1, 4) },
        { 946684799, mk_time(23, 59, 59), mk_date(1999, 12, 31, 5) },
        { 230959800, mk_time(3, 30, 00), mk_date(1977, 04, 27, 3) },
        { 4294967295, mk_time(6, 28, 15), mk_date(2106, 02, 07, 7) },
    };
    u32 len = sizeof(test_data) / sizeof(test_data[0]);

    eol();
    for(int i=0; i<len; ++i) {
        test_get_time(test_data[i].secs, test_data[i].time);
    }
    eol();
    for(int i=0; i<len; ++i) {
        test_get_date(test_data[i].secs, test_data[i].date);
    }
    print_summary();
    return 0;
}
