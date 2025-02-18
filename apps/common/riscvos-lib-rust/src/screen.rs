use crate::bindings;

#[derive(Default, Debug, Copy, Clone)]
pub struct Point {
    pub x: u8,
    pub y: u8
}

impl Point {
    pub fn new(x: u8, y: u8) -> Self {
        Self {
            x: x,
            y: y
        }
    }
}

impl From<bindings::ScrPoint> for Point {
    fn from(p: bindings::ScrPoint) -> Self {
        let msg = "Dimension too big for u8";
        Self {
            x: p.x.try_into().expect(msg),
            y: p.y.try_into().expect(msg)
        }
    }
}

pub fn get_size() -> Point {
    unsafe { bindings::scr_get_size().into() }
}

pub fn get_cursor_pos() -> Point {
    unsafe { bindings::get_cursor_pos().into() }
}

pub fn set_cursor_pos(x: u8, y: u8) {
    unsafe { bindings::set_cursor_pos(x.into(), y.into()); }
}

pub fn clear() {
    unsafe { bindings::clear_screen(); }
}
