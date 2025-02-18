use std::env;

fn main() {
    let out_dir = env::var("OUT").unwrap();
    println!("cargo::rustc-link-search=native={}", out_dir);
    println!("cargo::rustc-link-lib=static=common");
    println!("cargo:rustc-link-arg-bin=clock=-Tplatforms/virt.ld");
 }
