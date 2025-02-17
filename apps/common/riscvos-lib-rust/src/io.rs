use cty::c_char;
use crate::bindings;

fn print(s: &str, f: unsafe extern "C" fn(*const c_char)) {
    let bytes = s.as_bytes();
    let mut buffer = [0u8; 256];
    let len = bytes.len();
    assert!(len + 1 <= buffer.len(), "String too long for buffer");

    buffer[..len].copy_from_slice(bytes);
    buffer[len] = 0;

    unsafe { f(buffer.as_ptr() as *const cty::c_char); }
}

pub fn println(s: &str) {
    print(s, bindings::println);
}

pub fn prints(s: &str) {
    print(s, bindings::prints);
}

pub fn printc(c: u8) {
    unsafe { bindings::printc(c.into()); }
}

pub fn printw(w: u32) {
    unsafe { bindings::printw(w.into()); }
}

pub fn printnum(num: u32) {
    unsafe { bindings::printnum(num.into()); }
}

pub fn getc() -> i32 {
    unsafe { bindings::getc().into() }
}
