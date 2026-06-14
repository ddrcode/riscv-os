{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs.lib) optional optionals;
  inherit (pkgs.stdenv) isLinux;
  openocd-rpi = pkgs.openocd.overrideAttrs (old: {
    pname = "openocd";
    version = "rpi";
    src = pkgs.fetchFromGitHub {
      owner = "raspberrypi";
      repo = "openocd";
      rev = "sdk-2.2.0"; # or whatever recent tag you want to pin
      fetchSubmodules = true;
      hash = "sha256-WoGPHuOM+VcMvm+H4g7AKfladgYcPxBa9ix2uCZm29s="; # nix will tell you the real one on first build
    };
    nativeBuildInputs = (old.nativeBuildInputs or [ ])
      ++ [ pkgs.autoreconfHook pkgs.pkg-config pkgs.which ];
  });
in
pkgs.pkgsCross.riscv64-embedded.mkShell {
  nativeBuildInputs = with pkgs.buildPackages; [
    qemu
    minicom
    ccls
    dtc
    # openocd
    picotool
    gdb
    # bazelisk
    # ] ++ optionals isLinux [
    #   gdb
  ] ++ [ openocd-rpi ];
}

