// Tests of the system call interface (ecall), as documented in docs/api.md:
// a0-a4 arguments, a5 = function id; result in a0 (a1), error code in a5.
#include "types.h"
#include "assert.h"
#include "string.h"
#include "time.h"

#define SYSFN_SLEEP 1
#define SYSFN_IDLE 2
#define SYSFN_EXIT 4
#define SYSFN_GET_CFG 5
#define SYSFN_GET_DRV_CFG 6
#define SYSFN_GET_SECS_FROM_EPOCH 10
#define SYSFN_GET_DATE 11
#define SYSFN_GET_TIME 13
#define SYSFN_GET_CHAR 20
#define SYSFN_PRINT_CHAR 21
#define SYSFN_PRINT_STR 22
#define SYSFN_FB_INFO 40
#define SYSFN_FB_GET_CURSOR 41
#define SYSFN_FB_SET_CURSOR 42
#define SYSFN_VIDEO_SWITCH_MODE 52

#define ERR_NOT_SUPPORTED 3

#define CFG_STD_OUT 4
#define CFG_PLATFORM_NAME 20
#define CFG_SCREEN_DIMENSIONS 24
#define CFG_SCREEN_MODE 28

typedef struct { u32 a0; u32 a1; u32 a5; } SysResult;

// Raw system call (a3 and a4 are not used by any function tested here)
static SysResult sys(u32 id, u32 arg0, u32 arg1, u32 arg2) {
    register u32 a0 asm("a0") = arg0;
    register u32 a1 asm("a1") = arg1;
    register u32 a2 asm("a2") = arg2;
    register u32 a5 asm("a5") = id;
    asm volatile("ecall" : "+r"(a0), "+r"(a1), "+r"(a5) : "r"(a2) : "memory");
    SysResult r = { a0, a1, a5 };
    return r;
}

static void check(char* fn, char* what, u32 val, u32 expected) {
    print_test_name(fn, what);
    assert_eq(val, expected);
}

int main(void) {
    SysResult r;
    eol();

    r = sys(0, 0, 0, 0);
    check("sys_call", "id 0 -> not supported", r.a5, ERR_NOT_SUPPORTED);
    r = sys(7, 0, 0, 0);
    check("sys_call", "unassigned id 7 -> not supported", r.a5, ERR_NOT_SUPPORTED);
    r = sys(99, 0, 0, 0);
    check("sys_call", "id out of range -> not supported", r.a5, ERR_NOT_SUPPORTED);
    eol();

    r = sys(SYSFN_GET_CFG, CFG_PLATFORM_NAME, 0, 0);
    check("get_cfg", "platform name", strcmp((char*)r.a0, "virt"), 1);
    check("get_cfg", "no error", r.a5, 0);
    r = sys(SYSFN_GET_CFG, CFG_SCREEN_DIMENSIONS, 0, 0);
    check("get_cfg", "screen dimensions (height<<16 | width)", r.a0, (25 << 16) | 80);
    r = sys(SYSFN_GET_CFG, CFG_SCREEN_MODE, 0, 0);
    check("get_cfg", "screen mode", r.a0, 0);
    eol();

    r = sys(SYSFN_GET_CFG, CFG_STD_OUT, 0, 0);
    r = sys(SYSFN_GET_DRV_CFG, r.a0, 0, 0);
    check("get_drv_cfg", "stdout enabled (bit 0)", r.a0 & 1, 1);
    check("get_drv_cfg", "no error", r.a5, 0);
    eol();

    r = sys(SYSFN_PRINT_STR, (u32)"print_str works ", 0, 0);
    check("print_str", "result", r.a0, 0);
    check("print_str", "no error", r.a5, 0);
    r = sys(SYSFN_PRINT_CHAR, '!', 0, 0);
    check("print_char", "no error", r.a5, 0);
    r = sys(SYSFN_GET_CHAR, 0, 0, 0);
    check("get_char", "no input -> -1", r.a0, (u32)-1);
    check("get_char", "no error", r.a5, 0);
    eol();

    r = sys(SYSFN_GET_SECS_FROM_EPOCH, 0, 0, 0);
    check("get_secs_from_epoch", "no error (RTC present)", r.a5, 0);
    check("get_secs_from_epoch", "after 2025", r.a0 > 1735689600, 1);
    r = sys(SYSFN_GET_TIME, 0, 0, 0);
    check("get_time", "no error", r.a5, 0);
    check("get_time", "hours < 24", ((r.a0 >> 16) & 0xff) < 24, 1);
    r = sys(SYSFN_GET_DATE, 0, 0, 0);
    check("get_date", "no error", r.a5, 0);
    check("get_date", "month < 12", ((r.a0 >> 8) & 0xff) < 12, 1);
    eol();

    u8 info[9];
    r = sys(SYSFN_FB_INFO, 0, (u32)info, 0);
    check("fb_info", "no error", r.a5, 0);
    check("fb_info", "returns fb address", r.a0 != 0, 1);
    check("fb_info", "height", info[7], 25);
    check("fb_info", "width", info[8], 80);
    r = sys(SYSFN_FB_GET_CURSOR, 0, 0, 0);
    u32 saved_cursor = r.a0;
    check("fb_get_cursor", "no error", r.a5, 0);
    // no printing between set and get: output moves the cursor
    SysResult set = sys(SYSFN_FB_SET_CURSOR, 0, 3, 4);
    SysResult get = sys(SYSFN_FB_GET_CURSOR, 0, 0, 0);
    sys(SYSFN_FB_SET_CURSOR, 0, saved_cursor & 0xff, saved_cursor >> 8);
    check("fb_set_cursor", "returns y<<8 | x", set.a0, (4 << 8) | 3);
    check("fb_get_cursor", "reads back", get.a0, (4 << 8) | 3);
    eol();

    r = sys(SYSFN_VIDEO_SWITCH_MODE, 0, 0, 0);
    check("video_switch_mode", "same mode, no error", r.a5, 0);
    eol();

    r = sys(SYSFN_SLEEP, 40, 0, 0);
    check("sleep", "40ms returns, no error", r.a5, 0);
    r = sys(SYSFN_SLEEP, 1, 0, 0);
    check("sleep", "1ms returns, no error", r.a5, 0);
    eol();

    r = sys(SYSFN_EXIT, 7, 0, 0);
    check("exit", "outside of a program: returns exit code in a5", r.a5, 7);

    print_summary();
    return 0;
}
