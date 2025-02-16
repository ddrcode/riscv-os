use cty::{ c_char };
use core::str;

use crate::bindings;
use crate::errors::{ ConversionError };

trait NumToCStr {
    type Number;
    unsafe fn convert(num: Self::Number, buf: *mut c_char, base: u8) -> *mut c_char;
}

impl NumToCStr for u32 {
    type Number = u32;
    unsafe fn convert(num: u32, buf: *mut c_char, base: u8) -> *mut c_char {
        bindings::utoa(num, buf, base.into())
    }
}

impl NumToCStr for i32 {
    type Number = i32;
    unsafe fn convert(num: i32, buf: *mut c_char, base: u8) -> *mut c_char {
        bindings::itoa(num, buf, base.into())
    }
}


fn num_to_str<T: NumToCStr>(num: T::Number, buf: &mut [u8], base: u8) -> Result<&str, ConversionError> {
    assert!(base < 2 || base > 36, "Incorrect conversion base");

    if buf.is_empty() {
        return Err(ConversionError::BufferTooSmall);
    }

    let ret_ptr = unsafe { T::convert(num, buf.as_mut_ptr() as *mut c_char, base) };

    if ret_ptr.is_null() {
        return Err(ConversionError::BufferTooSmall);
    }

    let len = buf.iter().position(|&b| b == 0).ok_or(ConversionError::NoNullTerminator)?;

    str::from_utf8(&buf[..len]).map_err(|_| ConversionError::InvalidUtf8)
}

pub fn utoa(num: u32, buf: &mut [u8], base: u8) -> Result<&str, ConversionError> {
    num_to_str::<u32>(num, buf, base)
}

pub fn itoa(num: i32, buf: &mut [u8], base: u8) -> Result<&str, ConversionError> {
    num_to_str::<i32>(num, buf, base)
}
