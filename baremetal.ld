MEMORY
{
   /* qemu-system-risc64 virt machine */
   RAM (rwx)  : ORIGIN = 0x80000000, LENGTH = 128M
}

SECTIONS
{
    . = 0x80000000;
    .text : { *(.text) }
    . = ALIGN (CONSTANT (COMMONPAGESIZE));
    .data : { *(.data) }
    . = ALIGN (CONSTANT (COMMONPAGESIZE));
    PROVIDE( __global_pointer$ = . + 0x800 );
    PROVIDE(__stack_top = ORIGIN(RAM) + LENGTH(RAM));
}
