ENTRY(_start)

MEMORY
{
   /* qemu-system-risc64 virt machine */
   ROM (rx)    : ORIGIN = 0x01100000, LENGTH = 32K
   RAM (rwx)   : ORIGIN = 0x00000000, LENGTH = 64K
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
    . = 0;
    .text : ALIGN(32) {
        *(.text.start);
        *(.text.platform);
        *(.text .text.*)
    } > RAM
    /* . = ALIGN (CONSTANT (COMMONPAGESIZE)); */
    .rodata (READONLY) : ALIGN(32) { *(.rodata) } > RAM
    .bss : ALIGN(32) { *(.bss) }
    .data : ALIGN(32) { *(.data) }
    PROVIDE( __global_pointer$ = . + 0x800 );
    PROVIDE(__stack_top = ORIGIN(RAM) + LENGTH(RAM));
}

