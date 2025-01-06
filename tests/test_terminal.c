#include "types.h"
#include "drivers/video.h"
#include "assert.h"

int test_main(void) {
    eol();
    video_init();
    eol();
    return 0;
}
