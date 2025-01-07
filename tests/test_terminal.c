#include "types.h"
#include "shell.h"
#include "drivers/video.h"
#include "assert.h"

int test_main(void) {
    eol();
    video_init();
    video_repaint();
    shell_init();
    shell_command_loop();
    return 0;
}
