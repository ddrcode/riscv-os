{ pkgs ? import ./nixpkgs.nix {} }:

# Development shell for the whole repository: the OS (assembly, C) and
# the programs in apps/ (assembly, C, Rust). Enter it with `nix-shell` or
# `direnv allow` in the repository root; it applies to all subdirectories.
let
  inherit (pkgs.lib) optionals;
  inherit (pkgs.stdenv) isLinux;
in
  pkgs.pkgsCross.riscv64-embedded.mkShell {
    # The hardening flags (relro, PIE, ...) make no sense for a bare-metal
    # target and only produce linker warnings
    hardeningDisable = [ "all" ];

    nativeBuildInputs = with pkgs.buildPackages; [
      qemu
      minicom
      ccls
      dtc
      rustup                             # Rust toolchain is pinned in apps/rust-toolchain.toml
      rust-bindgen                       # generates apps/common/riscvos-lib-rust/src/bindings.rs
    ] ++ optionals isLinux [
      gdb
    ];
  }
