{ pkgs ? import <nixpkgs> {} }:

let
  inherit (pkgs.lib) optional optionals;
  inherit (pkgs.stdenv) isLinux;
in
  pkgs.pkgsCross.riscv64-embedded.mkShell {
    nativeBuildInputs = with pkgs.buildPackages; [
      qemu
      ccls
      rustup
      rust-bindgen
    ] ++ optionals isLinux [
      gdb
    ];
  }

