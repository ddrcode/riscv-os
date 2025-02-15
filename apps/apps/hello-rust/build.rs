use std::env;
use std::path::PathBuf;

fn main() {

    let libdir_path = PathBuf::from("../..")
        .canonicalize()
        .expect("cannot canonicalize path");

    let headers_path = libdir_path.join("common/bindings.h");
    let headers_path_str = headers_path.to_str().expect("Headers path is not a vlid string");

    // println!("cargo:rustc-link-search={}", libdir_path.to_str().unwrap());
    // println!("cargo:rustc-link-lib=common.a");

    // The bindgen::Builder is the main entry point
    // to bindgen, and lets you build up options for
    // the resulting bindings.
    let bindings = bindgen::Builder::default()
        // The input header we would like to generate
        // bindings for.
        .header(headers_path_str)
        // Tell cargo to invalidate the built crate whenever any of the
        // included header files changed.
        .parse_callbacks(Box::new(bindgen::CargoCallbacks::new()))
        // Finish the builder and generate the bindings.
        .generate()
        // Unwrap the Result and panic on failure.
        .expect("Unable to generate bindings");

    // Write the bindings to the $OUT_DIR/bindings.rs file.
    let out_path = PathBuf::from("..").join("bindings.rs");
    bindings
        .write_to_file(out_path)
        .expect("Couldn't write bindings!");

    println!("cargo:rustc-link-arg-bin=hello-rust=-Tplatforms/virt.ld");
 }
