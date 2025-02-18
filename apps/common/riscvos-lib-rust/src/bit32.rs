use crate::bindings;

pub fn bitlen(word: u32) -> u8 {
    unsafe { bindings::bitlen32(word.into()).into() }
}

pub fn getbit(word: u32, bit: u8) -> u8 {
    unsafe { bindings::getbit(word.into(), bit.into()).into() }
}

pub fn setbit(word: u32, bit: u8, val: u8) -> u32 {
    unsafe { bindings::setbit(word.into(), bit.into(), val.into()).into() }
}
