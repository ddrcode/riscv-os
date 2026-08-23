{ pkgs ? import ./nixpkgs.nix {} }:

let
  inherit (pkgs.lib) optional optionals;
  inherit (pkgs.stdenv) isLinux;
in
  pkgs.pkgsCross.riscv64-embedded.mkShell {
    nativeBuildInputs = with pkgs.buildPackages; [
      qemu
      minicom
      ccls
      dtc
    ] ++ optionals isLinux [
      gdb
    ];
  }

