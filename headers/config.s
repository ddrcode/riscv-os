# Generic
.equ debug, 1

.weak ENABLE_IRQ
.weak ENABLE_PLIC

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
