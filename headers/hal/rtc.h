#ifndef HAL_RTC_H
#define HAL_RTC_H

#include "types.h"

typedef struct RTCDriver RTCDriver;

struct RTCDriver {
    u32 base_addr;
    u32 (*config)(RTCDriver* self, u32 mask, u32 flags);
    u32 (*get_secs_from_epoch)(RTCDriver* self);
    U64 (*get_raw_data)(RTCDriver* self);
};

u32 rtc_get_secs_from_epoch(const RTCDriver* driver);
U64 rtc_read_raw_data(const RTCDriver* driver);

#endif
