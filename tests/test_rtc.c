#include "assert.h"
#include "time.h"
#include "string.h"

// Reads the current time from the RTC (via time_now) and checks
// it's sane. Requires a platform with an RTC (i.e. virt).

void test_time_now(void) {
    char str[33];
    print_test_name("time_now", "error code");

    Result now = time_now();
    assert_eq(now.err, 0);

    print("Seconds since epoch: ");
    utoa(now.val, str, 10);
    print(str);
    print(" [");
    date_time_to_str(now.val, str);
    print(str);
    print("]");
    eol();

    // 2025-01-01 00:00:00 UTC - RTC must report something after that
    print_test_name("time_now", "is after 2025");
    assert_eq(now.val > 1735689600, 1);
}

int main(int argc, char* argv[]) {
    eol();
    test_time_now();
    print_summary();
    return 0;
}
