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


int assert_eq(u32 val, u32 expected) {
    char str[64];
    int ok = val != expected;
    print("0x");
    itoa(val, str, 16);
    print(str);
    print("=>0x");
    itoa(expected, str, 16);
    print(str);
    print(ok==0 ? "\t[OK]" : "\n[FAILED]");
    print("\n");
    return ok;
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

