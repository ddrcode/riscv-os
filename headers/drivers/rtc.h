#ifndef RTC_H
#define RTC_H

#include "types.h"

u32 rtc_read_time(void);
u32 rtc_time_in_sec(void);
u32 rtc_get_time(void);
u32 rtc_get_date(void);

#endif
