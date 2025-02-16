#![no_std]
#![no_main]

extern crate cty;

use core::arch::global_asm;
use core::ptr;
use core::panic::PanicInfo;

#[path = "../../../build/bindings.rs"]
mod bindings;

// include!("../../../build/bindings.rs"));

// global_asm!(include_str!("../../../common/startup.s"));

fn uart_print(message: &str) {
    const UART: *mut u8 = 0x10000000 as *mut u8;

    for c in message.chars() {
        unsafe {
        	      ptr::write_volatile(UART, c as u8);
        }
    }
}

#[no_mangle]
pub extern "C" fn main() -> i32 {
    let c_str: &[u8] = b"Hello from Rust!\0";

    unsafe {
        // Pass the pointer to the C function.
        let ret = bindings::println(c_str.as_ptr() as *const cty::c_char);
        let _ = ret; // Optionally use the result.
    }
    0
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    uart_print("Something went wrong.");
    loop {}
}
