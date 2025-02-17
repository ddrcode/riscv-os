use crate::bindings;

pub fn abs(val: i32) -> i32 {
    unsafe { bindings::abs(val.into()).into() }
}

pub fn sign(val: i32) -> i8 {
    unsafe { bindings::sign(val.into()).into() }
}

pub fn udiv(x: u32, y: u32) -> u32 {
    unsafe { bindings::udiv32(x.into(), y.into()).into() }
}

pub fn urem(x: u32, y: u32) -> u32 {
    unsafe { bindings::urem32(x.into(), y.into()).into() }
}

pub fn div(x: i32, y: i32) -> i32 {
    unsafe { bindings::div32(x.into(), y.into()).into() }
}

pub fn rem(x: i32, y: i32) -> i32 {
    unsafe { bindings::rem32(x.into(), y.into()).into() }
}

pub fn pow(x: i32, y: i32) -> i32 {
    unsafe { bindings::pow32(x.into(), y.into()).into() }
}

pub fn mul(x: i32, y: i32) -> i64 {
    unsafe { bindings::mul32(x.into(), y.into()).into() }
}
