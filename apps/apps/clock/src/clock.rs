// Digital clock - rendered with character-based "pixels"
//
// author: David de Rosier
// https://github.com/ddrcode/riscv-os
//
// See LICENSE file for license details.

#![no_std]
#![no_main]

mod fonts;

use core::str;
use riscvos::{
    error::OSError,
    screen::{clear, set_cursor_pos},
    io::{ println, getc },
    sysutils::sleep,
    terminal,
    time::*
};
use fonts::{ FONT_HEIGHT, DIGITS };

const CLOCK_BLOCK: u32 = 0x1f7e6;
const TICK_TIME: u32 = 150;
const LINE_WIDTH: u8 = 39;


#[no_mangle]
pub extern "C" fn main(_argc: u32, _argv: *const *const u8) -> i32 {
    terminal::set_mode(terminal::TerminalMode::Wide);

    if now().is_err() {
        println("RTC not found on this device");
        return OSError::NotSupported as i32;
    }

    clear();
    terminal::hide_cursor();
    terminal::set_screencode(33, CLOCK_BLOCK);

    let _ = clock_loop();

    clear();
    terminal::reset();
    terminal::show_cursor();
    0
}


/// Main program loop
fn clock_loop() -> Result<(), OSError> {
    let mut buff = [0u8; 9];
    let mut prev_time = 0u32;
    let (x, y) = get_clock_position();

    loop {
        let curr_time = now()?;
        if curr_time != prev_time {
            let time = get_time(curr_time);
            show_time(time_to_str(&time, &mut buff).unwrap(), x, y);
            prev_time = curr_time;
        }
        if getc() > 0 { break Ok(()); }
        sleep(TICK_TIME);
    }
}


/// Computes the x,y position of top-left corner of the clock
/// to keep it centered on the screen
fn get_clock_position() -> (u8, u8) {
    let scr_size = riscvos::screen::get_size();
    let x = (scr_size.x - LINE_WIDTH) >> 1;
    let y = (scr_size.y - (FONT_HEIGHT as u8)) >> 1;
    (x, y)
}


/// Prepares a single line of "pixels" to render
fn digit_line(ch: u8, row: usize) -> impl Iterator<Item = u8> {
    let width = if ch == b':' { 2 } else { 6 };
    let index = (ch - b'0') as usize;
    let d = DIGITS[index][row];
    (0..width).rev().map(move |k| 32 + ((d >> k) & 1))
}


/// Renders given time as rows of character-based "pixels"
fn show_time(time: &str, x: u8, y: u8) {
    set_cursor_pos(x, y);
    let bytes = time.as_bytes();
    let mut buf = [32u8; (LINE_WIDTH+1) as usize];

    for row in 0..FONT_HEIGHT {
        let mut idx = 0;

        for &ch in bytes {
            for pixel in digit_line(ch, row) {
                buf[idx] = pixel;
                idx += 1;
            }
        }

        let line = str::from_utf8(&buf[1..]).expect("Invalid UTF-8");
        println(line);
    }
}
