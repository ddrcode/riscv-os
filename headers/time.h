#ifndef TIME_H
#define TIME_H

#include "types.h"

u32 get_time(u32 secs);
u32 get_date(u32 secs);
i32 time_to_str(u32 time, char* str);

#endif
