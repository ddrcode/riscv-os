#include "io.h"
#include "types.h"
#include "unicode.h"


int main() {
    u32 japanese[] = {0x3053, 0x3093, 0x306B, 0x3061, 0x306F, 0x4E16, 0x754C};
    u32 bytes;
    for (int i = 0; i < 7; i++) {
        utf_encode(japanese[i], &bytes);
        printw(bytes);
    }
    printc('\n');

    prints("Start typing (press ~ for clear screen)...\n");
    int c;
    while (1) {
        while((c = getc()) <= 0);
        switch (c) {
            case 10:
            case 13:
                printc('\n');
                break;
            case '~':
                prints("\033[2J");
                prints("\033[H");
                break;
            case 127:
                printc('\b');
                printc(' ');
                printc('\b');
                break;
            default:
                printc(c);
        }
    }
}
