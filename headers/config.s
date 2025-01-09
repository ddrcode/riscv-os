.weak ENABLE_IRQ
.weak ENABLE_PLIC
.weak HAS_RTC

.ifdef m_virt
    .equ ENABLE_IRQ, 1
    .equ ENABLE_PLIC, 1
    .equ HAS_RTX, 1
    .include "config-virt.s"
.endif

.ifdef m_sifive_u
    .include "config-sifive_u.s"
.endif
