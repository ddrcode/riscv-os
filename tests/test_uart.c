#include "io.h"
#include "types.h"

int main() {
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
