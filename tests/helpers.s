.section .text

.global regarr

# Copies registers a1-a5 to provided array (a0)
# Helpful in case when a function returns more than
# a single value
.type regarr, @function
regarr:
    sw a1, (a0)
    sw a2, 4(a0)
    sw a3, 8(a0)
    sw a4, 12(a0)
    sw a5, 16(a0)
    ret
