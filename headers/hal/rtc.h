#ifndef HAL_RTC_H
#define HAL_RTC_H

#include "types.h"

typedef struct {
    u32 base_addr;
    u32 (*config)(u32, u32, u32);
    u32 (*get_secs_from_epoch)();
} RTCDriver;

u32 rtc_get_secs_from_epoch(const RTCDriver* driver);

#endif
