# SPAASM-Zadanie1

Prints file content, if there are repeating lines, they will be printed only once.

## Additional features:
Arguments -h, -p

**2.1** -p - Output paging, waits for user input upon filling the screen.

-h - Prints information about the program, then proceeds with its normal function.

**2.7** Supports files above **64KB**, since the file is read character-by-character.\
File has to be of a specific format - each line no longer than 80 characters (console width), and ended with a `0D0A` hexadecimal newline, otherwise paging isnt guaranteed to work.

## Test cases

### File `lipsum.txt`

    Lorem ipsum dolor sit amet, consectetur eiusmod tempor incididunt.
    Ut labore et dolore magna aliqua. Dui ut ornare lectus egestas.
    Ultricies leo integer malesuada nunc. Ut tortor potenti nullam. <
    Ultricies leo integer malesuada nunc. Ut tortor potenti nullam. <
    Ultricies leo integer malesuada nunc. Ut tortor potenti nullam. <
    Accumsan ac ut. Integer quis sed vulputate mi sit amet mauris.
    Cursus in hac habitasse platea dictumst.
    Praesent tristique magna sit amet purus gravida quis blandit.
    Vel quam elementum pulvinar etiam non quam suspendisse faucibus.
    Sollicitudin tempor id eu nisl nunc mi ipsum faucibus vitae.
    Ut ornare lectus sit amet est placerat in egestas erat. <
    Ut ornare lectus sit amet est placerat in egestas erat. <
    Ut ornare lectus sit amet est placerat in egestas erat. <
    Non nisi est sit amet. Egestas pretium aenean vestibulum.
    Mi sit amet quis imperdiet massa. Molestie eu facilisis. <
    Mi sit amet quis imperdiet massa. Molestie eu facilisis. <
    Cursus metus aliquam eleifend mi. Massa vitae tortor vel eros donec.

Expected output:

    C:\>dedup
    Enter file name: lipsum.txt
    Lorem ipsum dolor sit amet, consectetur eiusmod tempor incididunt.
    Ut labore et dolore magna aliqua. Dui ut ornare lectus egestas.
    Ultricies leo integer malesuada nunc. Ut tortor potenti nullam. <
    Accumsan ac ut. Integer quis sed vulputate mi sit amet mauris.
    Cursus in hac habitasse platea dictumst.
    Praesent tristique magna sit amet purus gravida quis blandit.
    Vel quam elementum pulvinar etiam non quam suspendisse faucibus.
    Sollicitudin tempor id eu nisl nunc mi ipsum faucibus vitae.
    Ut ornare lectus sit amet est placerat in egestas erat. <
    Non nisi est sit amet. Egestas pretium aenean vestibulum.
    Mi sit amet quis imperdiet massa. Molestie eu facilisis. <
    Cursus metus aliquam eleifend mi. Massa vitae tortor vel eros donec.

Deduplicated lines are marked in the file with `<` at the end to better distinguish them, has no actual impact on the program.

### File `abc.txt`

    a
    b
    c
    ... <incremental ascii>
    w
    x
    y
    z
    1
    2
    3
    ... <incremental numbers>
    23
    24
    25
    26
    26
    26
    26
    26
    26
    26
    26
    26
    26
    26
    27
    28
    28
    28


    28
    28
    27

Expected output

    a
    b
    c
    ... <incremental ascii>
    w
    x
    y
    z
    1
    2
    3
    ... <incremental numbers>
    23
    24
    25
    26
    27
    28

    28
    27


### File `long.txt`

    ... <contains lipsum.txt multiple times to reach a size greater than 64KB>

Used to show support for files greater than 64KB.