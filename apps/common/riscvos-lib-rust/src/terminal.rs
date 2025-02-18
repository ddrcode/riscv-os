use crate::bindings;

pub fn show_cursor() {
    unsafe { bindings::term_show_cursor(); }
}

pub fn hide_cursor() {
    unsafe { bindings::term_hide_cursor(); }
}

pub fn reset() {
    unsafe { bindings::term_reset(); }
}

pub fn set_screencode(code: u8, unicode: u32) {
    unsafe { bindings::term_set_screencode(code.into(), unicode.into()); }
}
