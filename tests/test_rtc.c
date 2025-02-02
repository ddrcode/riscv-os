#include "assert.h"
#include "drivers/rtc.h"
#include "string.h"

void query_rtc(int times) {
    print("Quering RTC\n");

    while(times--) {
        char strlo[33], strhi[33];
        u32 tlo, regs[6];
        tlo = rtc_read_time();
        regarr(regs);
        u32 thi = regs[0];

        utoa(tlo, strlo, 10);
        utoa(thi, strhi, 10);

        print("hi: ");
        print(strhi);
        print(", lo: ");
        print(strlo);
        eol();
    }
}

void time_in_sec() {
    print("Time in sec: ");
    char strlo[33], strhi[33];
    u32 tlo, regs[6];
    tlo = rtc_time_in_sec();
    regarr(regs);
    u32 thi = regs[0];

    utoa(tlo, strlo, 10);
    utoa(thi, strhi, 10);

    print("hi: ");
    print(strhi);
    print(", lo: ");
    print(strlo);
    eol();
}

int main(void) {
    eol();
    query_rtc(10);
    eol();
    time_in_sec();
    print_summary();
    return 0;
}
