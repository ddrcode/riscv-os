fn main() {
    println!("cargo:rustc-link-arg-bin=hello-rust=-Tplatforms/virt.ld");
 }
