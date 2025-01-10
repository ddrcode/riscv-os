# Generic
.equ debug, 0


.weak ENABLE_IRQ
.weak ENABLE_PLIC
.weak HAS_RTC

.ifdef m_virt
    .equ ENABLE_IRQ, 1
    .equ ENABLE_PLIC, 1
    .equ HAS_RTC, 1
    .include "config-virt.s"
.endif

.ifdef m_sifive_u
    .equ ENABLE_IRQ, 1
    .equ ENABLE_PLIC, 1
    .include "config-sifive_u.s"
.endif
