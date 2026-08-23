ENTRY(_start)

MEMORY
{
   /* Program area of the OS (PROGRAM_RAM in headers/config.s) */
   RAM (rwx)   : ORIGIN = 0x80100000, LENGTH = 256K
}

SECTIONS
{
    . = 0x80100000;
    .text : ALIGN(32) {
        *(.text.start);
        *(.text .text.*)
    } > RAM
    .rodata : ALIGN(32) { *(.rodata .rodata.* .srodata .srodata.*) } > RAM
    .data : ALIGN(32) { *(.data .data.* .sdata .sdata.*) } > RAM

    /* .bss is not part of the binary; it's zeroed by common/startup.s */
    .bss : ALIGN(32) {
        __bss_start = .;
        *(.bss .bss.* .sbss .sbss.* COMMON)
        . = ALIGN(4);
        __bss_end = .;
    } > RAM
}
