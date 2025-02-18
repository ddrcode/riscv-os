use crate::bindings;

pub fn sleep(ms: u32) {
    unsafe { bindings::sleep(ms.into()); }
}
