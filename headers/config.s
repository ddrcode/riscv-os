.ifndef __CONFIG_S__
.equ __CONFIG_S__, 1

# Generi
.equ DEBUG, 0

.weak ENABLE_IRQ
.weak ENABLE_PLIC

.equ PMP_ENABLED, 1
.equ PMP_LOCKED, 1
.set PMP_CUSTOM_CONFIG, 0


# Global / default settings
# Don't change these, but edit your platform-specifc config file instead.

# Specifies the minimum stack size allocated per function
# when stack_alloc macro is used without any argument.
# If the macro is called with argument smaller than this value,
# the value will be defaulted to this one
# The ILP32I ABI specifies that individual stack-chunk should be
# 16-bytes long.
.set MIN_STACK_ALLOC_CHUNK, 16

# Defines the total size of a stack used be IRQ handlers.
.set ISR_STACK_SIZE, 4096

# Indicates whether the platform on which the OS will be running has
# M or Zmmul extension. If not, the OS provides a fallback solution
# that lets to execute math instructions (div, mul, etc) without any
# further changes. Means the OS should be using math instructions of
# RISC-V assembly, regardless the target platform.
.set HAS_EXTENSION_M, 1
.set HAS_EXTENSION_ZMMUL, 1

# Address where user programs being loaded
.set PROGRAM_RAM, 0x80100000
.set FLASH1_BASE, 0x22000000

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

.ifdef m_sifive_e
    .equ ENABLE_IRQ, 1
    .equ ENABLE_PLIC, 1
    .include "platforms/config-sifive_e.s"
.endif

.endif
