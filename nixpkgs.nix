# Pinned nixpkgs, shared by ./shell.nix and ./apps/shell.nix, so the toolchain
# (gcc, binutils, qemu, bindgen, ...) is reproducible regardless of the local channel.
#
# To upgrade: pick a new nixpkgs commit, put it in `rev`, then set `sha256` to
# the output of:
#     nix-prefetch-url --unpack https://github.com/NixOS/nixpkgs/archive/<rev>.tar.gz
#
# Current pin: nixpkgs-unstable as of 2026-08-23
# (gcc 15.2.0, binutils 2.46, qemu 11.0.1, rust-bindgen 0.72.1)
let
  rev = "35d3407a3816f3b341d8cf1d60abaf2b7b8166ac";
  sha256 = "0qjclv3qc0c8k264v1n0cx2avw2phqy57wp0rfbm53ism5v0z1h6";
in
import (fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
  inherit sha256;
})
