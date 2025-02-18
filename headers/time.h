#ifndef TIME_H
#define TIME_H

#include "types.h"

typedef struct {
    byte seconds;
    byte minutes;
    byte hours;
} Time;

typedef struct {
    byte day;
    byte month;
    byte year;      // year - 1900
    byte dow;       // day-of-week
} Date;

Time get_time(u32 secs);
Date get_date(u32 secs);
char* time_to_str(Time time, char* str);
char* date_to_str(Date date, char* str);
char* date_time_to_str(u32 date, char* str);
Result time_now(void);

#endif
