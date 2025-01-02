#include "assert.h"
#include "uart.h"
#include "string.h"

void print(char* str) {
    puts(str);
}

void print_test_name(char* prefix, char* case_name) {
    print("Testing ");
    print(prefix);
    print(" (");
    print(case_name);
    print("): ");
}


int asser_eq(u32 val, u32 expected) {
    return 0;
}

int assert_arr(u32* vals, u32* expected, i32 len) {
    int ok = 0;
    char str[64];
    for (int i=0; i < len; ++i) {
        if (vals[i] != expected[i]) {
            ok = 1;
        }
        print("0x");
        itoa(vals[i], str, 16);
        print(str);
        print("=>0x");
        itoa(expected[i], str, 16);
        print(str);
        if (i < len-1 ) print(", ");
    }
    print(ok==0 ? "\t[OK]" : "\n[FAILED]");
    print("\n");
    return ok;
}

