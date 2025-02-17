use cty::c_char;
use crate::bindings;
use crate::string::buf_to_str;
use crate::errors::ConversionError;

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

pub fn now() -> u32 {
    unsafe { bindings::time_now().into() }
}

pub fn get_time(secs: u32) -> Time {
    unsafe { bindings::get_time(secs.into()).into() }
}

pub fn time_to_str<'a, 'b>(time: &'a Time, buf: &'b mut [u8]) -> Result<&'b str, ConversionError> {
    let ptr = unsafe {
        bindings::time_to_str(bindings::Time::from(*time), buf.as_mut_ptr() as *mut c_char)
    };
    buf_to_str(buf)
}
