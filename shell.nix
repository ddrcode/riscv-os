  { pkgs ? import <nixpkgs> {} }:

  pkgs.pkgsCross.riscv64-embedded.mkShell {
    nativeBuildInputs = with pkgs.buildPackages; [ qemu ];
  }

