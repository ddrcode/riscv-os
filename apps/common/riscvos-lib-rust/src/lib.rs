#![no_std]
#![no_main]

extern crate cty;

use core::panic::PanicInfo;

#[allow(non_camel_case_types)]
#[allow(non_snake_case)]
#[allow(non_upper_case_globals)]
mod bindings;

pub mod io;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
