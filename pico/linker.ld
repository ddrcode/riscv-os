ENTRY(_start)

MEMORY
{
    FLASH(rx)  : ORIGIN = 0x10000000, LENGTH = 2048K
    RAM(rwx)   : ORIGIN = 0x20000000, LENGTH = 512K
}

SECTIONS
{
    . = ORIGIN(FLASH);

    .text : {
        KEEP(*(.text._start))
        *(.text*)
    } > FLASH

    .rodata : {
        *(.rodata*)
    } > FLASH

    .data : {
        __data_start = .;
        *(.data*)
        __data_end = .;
    } > RAM AT > FLASH

    __data_load = LOADADDR(.data);

    .bss : {
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        __bss_end = .;

        PROVIDE(__global_pointer$ = . + 0x800);
    } > RAM

    PROVIDE(__stack_top = ORIGIN(RAM) + LENGTH(RAM));
}
