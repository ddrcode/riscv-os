MEMORY
{
   /* qemu-system-risc64 virt machine */
   RAM (rwx)  : ORIGIN = 0x80000000, LENGTH = 128M
}

SECTIONS
{
    . = 0x80000000;
    .text : {
        *(.text)
		}
    . = ALIGN (CONSTANT (COMMONPAGESIZE));
    .data : {
        *(.data)
		}
    PROVIDE(__stack_top = ORIGIN(RAM) + LENGTH(RAM));
}
