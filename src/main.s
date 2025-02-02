# System's main function
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "macros.s"

.global main

.section .text

# This is the main function of the system, executed
# after the initialization. See startup.s
# to check the initialization procedure
fn main
    call shell_init
    ret
endfn
