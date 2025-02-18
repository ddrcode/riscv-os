use cty::c_char;
use crate::bindings;
use crate::string::buf_to_str;
use crate::error::*;

#[derive(Clone, Copy)]
pub struct Time {
    sec: u8,
    min: u8,
    hour: u8
}

impl From<bindings::Time> for Time {
    fn from(time: bindings::Time) -> Self {
        Self {
            sec: time.seconds.into(),
            min: time.minutes.into(),
            hour: time.hours.into()
        }
    }
}

impl From<Time> for bindings::Time {
    fn from(time: Time) -> Self {
        Self {
            seconds: time.sec.into(),
            minutes: time.min.into(),
            hours: time.hour.into()
        }
    }
}

#[derive(Clone, Copy)]
pub struct Date {
    day: u8,
    month: u8,
    year: u8,
    dow: u8
}

impl From<bindings::Date> for Date {
    fn from(d: bindings::Date) -> Self {
        Self {
            day: d.day.into(),
            month: d.month.into(),
            year: d.year.into(),
            dow: d.dow.into()
        }
    }
}

impl From<Date> for bindings::Date {
    fn from(d: Date) -> Self {
        Self {
            day: d.day.into(),
            month: d.month.into(),
            year: d.year.into(),
            dow: d.dow.into()
        }
    }
}

pub fn now() -> Result<u32, OSError> {
    let res = unsafe { bindings::time_now() };
    match res.err {
        0 => Ok(res.val.into()),
        _ => Err(OSError::NotSupported)
    }
}

pub fn get_time(secs: u32) -> Time {
    unsafe { bindings::get_time(secs.into()).into() }
}

pub fn time_to_str<'a, 'b>(time: &'a Time, buf: &'b mut [u8]) -> Result<&'b str, ConversionError> {
    let ptr = unsafe {
        bindings::time_to_str(bindings::Time::from(*time), buf.as_mut_ptr() as *mut c_char)
    };
    if ptr.is_null() {
        return Err(ConversionError::BufferTooSmall);
    }
    buf_to_str(buf)
}

pub fn get_date(secs: u32) -> Date {
    unsafe { bindings::get_date(secs.into()).into() }
}

pub fn date_to_str<'a, 'b>(date: &'a Date, buf: &'b mut [u8]) -> Result<&'b str, ConversionError> {
    let ptr = unsafe {
        bindings::date_to_str(bindings::Date::from(*date), buf.as_mut_ptr() as *mut c_char)
    };
    if ptr.is_null() {
        return Err(ConversionError::BufferTooSmall);
    }
    buf_to_str(buf)
}

pub fn date_time_to_str(secs: u32, buf: &mut [u8]) -> Result<&str, ConversionError> {
    let ptr = unsafe {
        bindings::date_time_to_str(secs.into(), buf.as_mut_ptr() as *mut c_char)
    };
    if ptr.is_null() {
        return Err(ConversionError::BufferTooSmall);
    }
    buf_to_str(buf)
}
