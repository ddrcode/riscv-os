ENTRY(_start)

MEMORY
{
    FLASH(rx) : ORIGIN = 0x10000000, LENGTH = 2M
    RAM(rwx) : ORIGIN =  0x20000000, LENGTH = 520k
}

SECTIONS
{
    . = ORIGIN(FLASH);
    .text : {
        *(.text)         /* Code */
    } > FLASH

    .rodata : {
        *(.rodata)
    } > FLASH

    .data : {
        *(.data)
    } > RAM AT > FLASH

    .bss : {
        *(.bss)
    PROVIDE( __global_pointer$ = . + 0x800 );
    PROVIDE(__stack_top = ORIGIN(RAM) + LENGTH(RAM));
    } > RAM

}

