// mod bindings;
use crate::bindings;

pub fn println(s: &str) {
    let bytes = s.as_bytes();
    let mut buffer = [0u8; 256];
    let len = bytes.len();
    assert!(len + 1 <= buffer.len(), "String too long for buffer");

    buffer[..len].copy_from_slice(bytes);
    buffer[len] = 0;

    unsafe { bindings::println(buffer.as_ptr() as *const cty::c_char); }
}
