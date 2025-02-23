use crate::bindings;

#[repr(u8)]
pub enum TerminalMode {
    Normal = 0,
    Wide = 1
}

impl From<bindings::u8_> for TerminalMode {
    fn from(mode: bindings::u8_) -> Self {
        if mode == 1 {
            TerminalMode::Wide
        } else {
            TerminalMode::Normal
        }
    }
}

impl From<TerminalMode> for bindings::u8_ {
    fn from(mode: TerminalMode) -> Self {
        match mode {
            TerminalMode::Normal => 0.into(),
            TerminalMode::Wide => 1.into()
        }
    }
}

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


pub fn get_mode() -> TerminalMode {
    unsafe { bindings::term_get_mode().into() }
}


pub fn set_mode(mode: TerminalMode) {
    unsafe { bindings::term_set_mode(mode.into()) }
}
