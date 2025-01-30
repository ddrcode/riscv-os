    .ifndef __CONFIG_S__
.equ __CONFIG_S__, 1

# Generic
.equ DEBUG, 0



# Global / default settings
# Don't change these, but edit your platform-specifc config file instead.

# Specifies the minimum stack size allocated per function
# when stack_alloc macro is used without any argument.
# If the macro is called with argument smaller than this value,
# the value will be defaulted to this one
# The ILP32I ABI specifies that individual stack-chunk should be
# 16-bytes long.
.set MIN_STACK_ALLOC_CHUNK, 4


# Indicates whether the platform on which the OS will be running has
# M or Zmmul extension. If not, the OS provides a fallback solution
# that lets to execute math instructions (div, mul, etc) without any
# further changes. Means the OS should be using math instructions of
# RISC-V assembly, regardless the target platform.
.set HAS_EXTENSION_M, 1
.set HAS_EXTENSION_ZMMUL, 1


#--------------------------------------

# All the above settings can be overwritten in the individaul
# per-machine configs

.equ SCREEN_WIDTH, 40
.equ SCREEN_HEIGHT, 25



# Memory
.equ MIN_STACK_ALLOC_CHUNK, 16

# Screen
.equ SCREEN_WIDTH, 40
.equ SCREEN_HEIGHT, 25



.equ SCREEN_OVER_SERIAL_HBORDER, 4
.equ SCREEN_OVER_SERIAL_VBORDER, 1

.equ BORDER_COLOR, 1


# System

.endif

