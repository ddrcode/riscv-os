#![no_std]
#![no_main]

use core::slice;
use core::str;

// Only if your asm code doesn't execute main
global_asm!(include_str!("startup.s"));

const UART_BASE_ADDR: u32 = 0x4000_000;

#[no_mangle]
pub extern "C" fn main(argc: u32, argv: *const *const u8) -> i32 {
    write_to_register(UART_BASE_ADDR as *mut u32, 42);
    0
}

fn write_to_register(addr: *mut u32, value: u32) {
    unsafe {
        core::ptr::write_volatile(addr, value);
    }
}

// Device-specific constant, defined in a HAL or memory config file
const UART_TX: usize = 0x1000_0000;

// Public safe API
pub fn uart_drv_write(byte: u8) {
    unsafe {
        core::ptr::write_volatile(UART_TX as *mut u8, byte);
    }
}


use riscv::register::{mcause, mepc, mtval, mstatus};

#[no_mangle]
pub extern "C" fn machine_trap_handler() {
    let cause = mcause::read().cause();

    match cause {
        mcause::Trap::Exception(mcause::Exception::UserEnvCall) => {
            handle_syscall();
        }
        _ => {
            panic!("Unhandled trap: {:?}", cause);
        }
    }
}

fn handle_syscall() {
    let syscall_number: usize;
    let arg0: usize;

    unsafe {
        core::arch::asm!(
            "mv {0}, a7",
            "mv {1}, a0",
            "mv {2}, a1",
            out(reg) syscall_number,
            out(reg) arg0,
            options(nostack)
        );
    }

    match syscall_number {
        1 => uart_write(arg0 as u8),
        2 => timer_read(), // or whatever your system call table defines
        _ => panic!("Unknown syscall"),
    }
}


pub fn uart_write(data: u8) {
    unsafe {
        core::arch::asm!(
            "mv a0, {0}",
            "li a7, 1",        // Let's say syscall number 1 = uart_write
            "ecall",
            in(reg) data,
            options(nostack)
        );
    }
}

#[global_allocator]
static ALLOCATOR: LockedHeap = LockedHeap::empty();

#[alloc_error_handler]
fn oom(_: Layout) -> ! {
    panic!("Out of Memory");
}

fn init_heap() {
    static mut HEAP_MEMORY: [u8; 1024] = [0; 1024];
    unsafe {
        ALLOCATOR.lock().init(HEAP_MEMORY.as_ptr() as usize, HEAP_MEMORY.len());
    }
}



