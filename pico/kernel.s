.equ SIO_BASE,  0xd0000000
.equ GPIO_OUT,  SIO_BASE + 0x010
.equ GPIO_OE,   SIO_BASE + 0x030
.equ GPIO_25,   (1 << 25)

.equ DELAY_COUNT,        5000000

.global _start

.section .text
.align 4

_start:
  # ... pad ISO clear, CTRL=SIO as before ...

  # Enable OE for GPIO25 only
  li a0, GPIO_OE
  li a1, GPIO_25
  sw a1, 0(a0)

  li s1, GPIO_25         # toggle pattern lives in s1
  add t0, s1, zero
  li a0, GPIO_OUT

loop:
  sw s1, 0(a0)           # drive GPIO_OUT = s1
  li a2, DELAY_COUNT
1:  addi a2, a2, -1
  bnez a2, 1b
  xor s1, s1, t0   # flip bit 25 in s1
  j loop
