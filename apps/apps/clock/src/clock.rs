#![no_std]
#![no_main]

mod fonts;

use core::str;
use riscvos::{ screen::{clear, set_cursor_pos}, io::{ println, getc }, sysutils::sleep, terminal, time::* };
use fonts::DIGITS;

const CLOCK_BLOCK: u32 = 0x1f7e6;

#[no_mangle]
pub extern "C" fn main(argc: u32, argv: *const *const u8) -> i32 {
    clear();
    terminal::hide_cursor();
    terminal::set_screencode(33, CLOCK_BLOCK);

    loop {
        let mut buff = [0u8; 9];
        let time = get_time(now());
        show_time(time_to_str(&time, &mut buff).unwrap());
        let c = getc();
        if c > 0 { break; }
        sleep(200);
    }

    clear();
    terminal::reset();
    terminal::show_cursor();
    0
}

fn show_time(time: &str) {
    set_cursor_pos(0, 7);
    let bytes = time.as_bytes();
    for i in 0..8 {
        let mut idx: usize = 0;
        let mut buf = [32u8; 40];
        for j in 0..8 {
            let b = bytes[j];
            let d = DIGITS[(b - 48) as usize][i];
            let len = if j==2 || j==5 { 2 } else { 6 };
            for k in 0..len {
                buf[idx] = 32 + ((d >> (len-k-1)) & 1);
                idx += 1;
            }
        }
        let s = str::from_utf8(&buf[1..]).expect("Invalid UTF-8");
        println(s);
    }
}
