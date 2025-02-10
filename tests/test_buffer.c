#include "types.h"
#include "assert.h"
#include "buffer.h"

void test_buffer_write(char* test_case) {
    print_test_name("buff_write", test_case);

    Buffer buff;
    byte data[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };

    buff_init(&buff, 8, data);

    buff_write(&buff, 1);
    buff_write(&buff, 2);
    buff_write(&buff, 3);

    u32 start = buff.start[0] | (buff.start[1] << 8);
    u32 end = buff.end[0] | (buff.end[1] << 8);
    assert_eq(start, 0);
    assert_eq(end, 3);

    assert_eq(data[0], 1);
    assert_eq(data[1], 2);
    assert_eq(data[2], 3);
}

void test_buffer_read(char* test_case) {
    print_test_name("buff_read", test_case);

    Buffer buff;
    byte data[8] = { 1, 2, 3, 4, 5, 6, 7, 8 };

    buff_init(&buff, 8, data);
    buff.end[0] = 2;

    int c1 = buff_read(&buff);
    int c2 = buff_read(&buff);

    u32 start = buff.start[0] | (buff.start[1] << 8);
    u32 end = buff.end[0] | (buff.end[1] << 8);

    assert_eq(start, 2);
    assert_eq(end, 2);
    assert_eq(c1, 1);
    assert_eq(c2, 2);
}

int main() {
    eol();

    test_buffer_write("");
    test_buffer_read("");

    print_summary();
    return 0;
}
