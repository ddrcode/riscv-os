#include "test.h"
#include "mem.h"
#include "uart.h"

void print(char* str) {
    puts(str);
}

char* citoa(u32 num, char* str, u32 base)
{
    u32 i = 0;
    u32 isNegative = 0;

    /* Handle 0 explicitly, otherwise empty string is
     * printed for 0 */
    if (num == 0) {
        str[i++] = '0';
        str[i] = '\0';
        return str;
    }

    // In standard itoa(), negative numbers are handled
    // only with base 10. Otherwise numbers are
    // considered unsigned.
    if (num < 0 && base == 10) {
        isNegative = 1;
        num = -num;
    }

    // Process individual digits
    while (num != 0) {
        u32 rem = num % base;
        str[i++] = (rem > 9) ? (rem - 10) + 'a' : rem + '0';
        num = num / base;
    }

    // If number is negative, append '-'
    if (isNegative)
        str[i++] = '-';

    str[i] = '\0'; // Append string terminator

    // Reverse the string
    mem_reverse(str, i);

    return str;
}

void asser_eq(u32 val, u32 expected) {

}

void assert_arr(u32* vals, u32* expected, i32 len) {
    int ok = 1;
    char str[64];
    for (int i=0; i < len; ++i) {
        if (vals[i] != expected[i]) {
            ok = 0;
        }
        print("0x");
        citoa(vals[i], str, 16);
        print(str);
        print("=>0x");
        citoa(expected[i], str, 16);
        print(str);
        if (i < len-1 ) print(", ");
    }
    print(ok ? "\t[OK]" : "\n[FAILED]");
    print("\n");
}

