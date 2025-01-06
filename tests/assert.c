#include "assert.h"
#include "io.h"
#include "string.h"
#include "types.h"

static u32 test_results = 0;
static u32 test_count = 0;

void print(char* str) {
    prints(str);
}

void print_test_name(char* prefix, char* case_name) {
    print("Testing ");
    print(prefix);
    print("(");
    print(case_name);
    print("): ");
}

inline void eol(void) {
    print("\n");
}


void print_summary(void) {
    char total[32], failed[32], ok[32];
    utoa(test_count, total, 10);
    utoa(test_results, failed, 10);
    utoa(test_count-test_results, ok, 10);
    print("\nRun ");
    print(total);
    print(" tests. ");
    print(failed);
    print(" tests failed, ");
    print(ok);
    print(" tests OK\n");
}

int assert_eq(u32 val, u32 expected) {
    char str[64];
    int ok = val != expected;
    print("0x");
    utoa(val, str, 16);
    print(str);
    print("=>0x");
    utoa(expected, str, 16);
    print(str);
    print(ok==0 ? "\t[OK]" : "\t[FAILED]");
    print("\n");

    ++test_count;
    test_results += ok;
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
    print(ok==0 ? "\t[OK]" : "\t[FAILED]");
    print("\n");

    ++test_count;
    test_results += ok;
    return ok;
}

int assert_str(char* val, char* expected) {
    int ok = !strcmp(val, expected);
    print(val);
    print("=>");
    print(expected);
    print(ok==0 ? "\t[OK]" : "\t[FAILED]");
    print("\n");
    ++test_count;
    test_results += ok;
    return ok;
}
