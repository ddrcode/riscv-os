#ifndef DRIVER_RTC_GOLDFISH_H
#define DRIVER_RTC_GOLDFISH_H

#include "types.h"
#include "hal/rtc.h"

RTCDriver* goldfish_rtc_init(RTCDriver* driver, u32 base_addr);

#endif
