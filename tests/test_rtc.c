#include "assert.h"
#include "rtc.h"
#include "string.h"

int query_rtc(int times) {

    while(times--) {
        char strlo[33], strhi[33];
        u32 tlo, regs[6];
        tlo = rtc_read_time();
        regarr(regs);
        u32 thi = regs[0];

        itoa(tlo, strlo, 10);
        itoa(thi, strhi, 10);

        print("hi: ");
        print(strhi);
        print(", lo: ");
        print(strlo);
        eol();
    }

    return 0;
}

int test_main(void) {
    eol();
    query_rtc(10);
    print_summary();
    return 0;
}
