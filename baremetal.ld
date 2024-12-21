MEMORY
{
   /* qemu-system-risc64 virt machine */
   ROM (rx)    : ORIGIN = 0x00001000, LENGTH = 64K
   FLASH0 (rx) : ORIGIN = 0x20000000, LENGTH = 32M
   FLASH1 (rx) : ORIGIN = 0x22000000, LENGTH = 32M
   RAM (rwx)   : ORIGIN = 0x80000000, LENGTH = 4M
}

SECTIONS
{
    . = 0x80000000;
    .text : { *(.text) } > RAM
    . = ALIGN (CONSTANT (COMMONPAGESIZE));
    .bss : { *(.bss) }
    .data : { *(.data) }
    . = ALIGN (CONSTANT (COMMONPAGESIZE));
    PROVIDE( __global_pointer$ = . + 0x800 );
    PROVIDE(__stack_top = ORIGIN(RAM) + LENGTH(RAM));
}

ENTRY(start)

