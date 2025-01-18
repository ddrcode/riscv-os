.ifndef __CONFIG_S__
.equ __CONFIG_S__, 1

# Generic
.equ DEBUG, 1

.weak ENABLE_IRQ
.weak ENABLE_PLIC


# Global / default settings
# Don't change these, but edit your platform-specifc config file instead.

# Specifies the minimum stack size allocated per function
# when stack_alloc macro is used without any argument.
# If the macro is called with argument smaller than this value,
# the value will be defaulted to this one
# The ILP32I ABI specifies that individual stack-chunk should be
# 16-bytes long.
.set MIN_STACK_ALLOC_CHUNK, 4

# Defines the total size of a stack used be IRQ handlers.
.set ISR_STACK_SIZE, 4096

# Indicates whether the platform on which the OS will be running has
# M or Zmmul extension. If not, the OS provides a fallback solution
# that lets to execute math instructions (div, mul, etc) without any
# further changes. Means the OS should be using math instructions of
# RISC-V assembly, regardless the target platform.
.set HAS_EXTENSION_M, 0
.set HAS_EXTENSION_ZMMUL, 1

#--------------------------------------

# All the above settings can be overwritten in the individaul
# per-machine configs

.ifdef m_virt
    .equ ENABLE_IRQ, 1
    .equ ENABLE_PLIC, 1
    .include "platforms/config-virt.s"
.endif

.ifdef m_sifive_u
    .equ ENABLE_IRQ, 1
    .equ ENABLE_PLIC, 1
    .include "platforms/config-sifive_u.s"
.endif

.endif
