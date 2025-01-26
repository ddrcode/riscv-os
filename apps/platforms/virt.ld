ENTRY(_start)

MEMORY
{
   /* qemu-system-risc64 virt machine */
   RAM (rwx)   : ORIGIN = 0x80100000, LENGTH = 256K
}

/* see https://sourceware.org/binutils/docs/ld/PHDRS.html */
/* PHDRS */
/* { */
/*     text PT_LOAD; */
/*     data PT_LOAD; */
/*     bss PT_LOAD; */
/* } */

SECTIONS
{
    . = 0x80100000;
    .text : ALIGN(32) {
        *(.text.start);
        *(.text .text.*)
    } > RAM
    .rodata : ALIGN(32) { *(.rodata) } > RAM
    .data : ALIGN(32) { *(.data) }
    .bss : ALIGN(32) { *(.bss) }
}

