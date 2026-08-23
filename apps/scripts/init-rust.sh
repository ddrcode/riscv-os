#!/bin/sh
# The toolchain (pinned nightly + rust-src) is declared in rust-toolchain.toml;
# rustup installs it automatically on first use. This script just does it explicitly.
cd "$(dirname "$0")/.." && rustup toolchain install
