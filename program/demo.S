# Tiny RV32I demo program for the included CPU.
# It continuously increments x1 and writes x1 to the LED output register.
#
# Memory-mapped I/O:
#   0x1000_0000 = LED output register
#   0x1000_0004 = 16-bit switch input register

    addi x1, x0, 0          # x1 = counter = 0
    lui  x2, 0x10000        # x2 = 0x1000_0000
loop:
    addi x1, x1, 1          # counter++
    sw   x1, 0(x2)          # LEDs = counter
    jal  x0, loop           # repeat forever
