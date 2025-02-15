#![no_std]
#![no_main]

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
   uart_print("Hello, world!\n");
    0
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
   uart_print("Something went wrong.");
   loop {}
}
