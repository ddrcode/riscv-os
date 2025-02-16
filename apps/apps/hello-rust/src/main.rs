#![no_std]
#![no_main]

use core::slice;
use core::str;

use riscvos::io::{ println, prints };

// include!("../../../build/bindings.rs"));

// global_asm!(include_str!("../../../common/startup.s"));


#[no_mangle]
pub extern "C" fn main(argc: u32, argv: *const *const u8) -> i32 {
    let hello = "Hello, ";

    prints(hello);

    unsafe {
        if argc > 1 && !argv.is_null() {
            let arg1_ptr = *argv.add(1);
            if !arg1_ptr.is_null() {
                let mut len = 0;
                while *arg1_ptr.add(len) != 0 {
                    len += 1;
                }
                let bytes = slice::from_raw_parts(arg1_ptr as *const u8, len);
                println(str::from_utf8(bytes).unwrap());
            }
        } else {
            println("Rust");
        }
    }

    0
}

