#![no_std]
#![no_main]

use riscvos::io::println;

// include!("../../../build/bindings.rs"));

// global_asm!(include_str!("../../../common/startup.s"));


#[no_mangle]
pub extern "C" fn main() -> i32 {
    let hello = "Hello from Rust";
    println(hello);
    0
}

