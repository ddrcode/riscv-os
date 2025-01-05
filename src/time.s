# Date/time functions
# author: David de Rosier
# https://github.com/ddrcode/riscv-os
#
# See LICENSE for license details.

.include "macros.s"

.equ SECS_PER_DAY, 86400

.global get_time
.global get_date
.global time_to_str

.section .text

# Computes time (hrs, min, sec)
# Arguments:
#     a0 - number of seconds since 1.01.1970
# Returns:
#     a0 - a 4-byte structure: 0 | hours | minutes | seconds
.type get_time, @function
get_time:
    li t0, SECS_PER_DAY
    remu a0, a0, t0                    # seconds of today (secs)

    li t0, 3600
    divu a1, a0, t0                    # hour = secs / 3600

    mul t1, a1, t0
    sub a0, a0, t1                     # secs -= hour*3600

    li t0, 60
    divu a2, a0, t0                    # min = secs / 60

    mul t1, a2, t0
    sub a3, a0, t1                     # seconds = secs - minutes*60

    mv a0, a1                          # prepare 4-byte result (0 | hr | min | sec)
    slli a0, a0, 8
    or a0, a0, a2
    slli a0, a0, 8
    or a0, a0, a3

    ret


# Heavily inspred by rtc_time64_to_tm from Linux rtc driver
# see: https://elixir.bootlin.com/linux/v6.12.6/source/drivers/rtc/lib.c#L52
#
# DateTime structure
# Addr    Size   Field
# 0       1      year-1900
# 1       1      month (0-11)
# 2       1      day of month (0-30)
# 3       1      day of week (0-6)
# 4       1      hour
# 5       1      minute
# 6       1      second
# 7       1      is leap year (0-1)
.type get_date, @function
get_date:
    .set year, 0
    .set month, 1
    .set day, 2
    .set dow, 3
    .set leap, 7

    stack_alloc
    li t2, 4                           # 4 is used for number of divs and muls below

    li t0, SECS_PER_DAY
    divu a1, a0, t0                    # number of days since 1.01.1970

    add t0, a1, a2                     # compute day of the week
    li t1, 7
    remu t0, t0, t1                    # knowing that 1.01.1970 was Thursday
    pushb t0, dow                      # and push on the stack

    li t1, 719468
    add a1, a1, t1                     # udays = days + 719468
    mul t0, t2, a1
    addi t0, t0, 3                     # tmp (t0) = 4 * udays + 3

    li t1, 146097
    divu a2, t0, t1                    # century (a2)
    remu a3, t0, t1
    divu a3, a3, t2                    # day of century (a3 = tmp % 146097 / 4)

    mul t0, a3, t2
    addi t0, t0, 3                     # tmp (t0) = day_of_century*4 + 3
    li t1, 2939745
    mulhu a3, t0, t1                   # year of century
    mul a4, t0, t1
    divu a4, a4, t1
    divu a4, a4, t2                    # day of year

    # from here
    # a0 - year, a1 - month, a2 - day, a4 - day of year
    li t1, 100
    mul a0, a2, t1
    add a0, a0, a3                     # year = 100*century + year_of_century

    li t2, 2141
    mul t0, a4, t2
    li t1, 132377
    add t0, t0, t1                     # tmp = 2141 * day_of_year + 132377

    srli a1, t0, 16                    # month = tmp >> 16

    li t1, 0xffff
    and a2, t0, t1
    divu a2, a2, t2                    # day = (tmp & 0xffff) / 2141 + 1
    inc a2

    sltiu t0, a4, 306                  # is_Jan_or_Feb
    bnez t0, 20f
        inc a0
        addi a1, a1, -12
20:
    addi a0, a0, -1900
    slli a0, a0, 8
    or a0, a0, a1
    slli a0, a0, 8
    or a0, a0, a2

    popb t0, dow
    slli t0, t0, 24
    or a0, a0, t0

    stack_free
    ret


# Converts time structure into string
# Arguments:
#     a0 - time
#     a1 - string pointer
# Returns
#     a0 - string pointer
.type time_to_str, @function
time_to_str:
    li a2, 6                           # string offset
    li a3, 10
1:
        and t0, a0, 0xff               # take the first byte of a0
        div t1, t0, a3                 # t1 = t0 / 10
        addi t1, t1, '0'
        add t2, a1, a2                 # compute address
        sb t1, 0(t2)

        rem t1, t0, a3                 # t1 = t0 % 10
        addi t1, t1, '0'
        sb t1, 1(t2)

        srli a0, a0, 8                 # a0 = a0 >> 8
        addi a2, a2, -3

        bltz a2, 2f                    # exit if offset < 0
            li t1, ':'                 # otherwise add ":" character
            sb t1, -1(t2)

        j 1b
2:
    sb zero, 8(a1)                     # close the string
    mv a0, a1                          # return string address
    ret

