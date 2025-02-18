use cty::c_uint;
use crate::bindings;

pub fn encode(codepoint: u32, bytes: &mut u32) -> u8 {
    unsafe { bindings::utf_encode(codepoint.into(), bytes as *mut c_uint).into() }
}
