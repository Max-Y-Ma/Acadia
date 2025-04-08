.section .text
.globl _start
_start:


    # Load RSA value
    lui x1, 0x70008

    xor x2, x2, x2
    lui x2, 0x4
    addi x2, x2, 0x7d6
    sw x2, 0(x1)

    xor x2, x2, x2
    lui x2, 0x4
    addi x2, x2, 0x07d6
    sw x2, 4(x1)

    xor x2, x2, x2
    lui x2, 0x2
    addi x2, x2, 0x0797
    sw x2, 4(x1)


    xor x2, x2, x2
    lui x2, 0xf
    addi x2, x2, 0x70B
    addi x2, x2, 0x70B
    sw x2, 8(x1)

    sw x2, 12(x1)
    xor x2, x2, x2

_loop:
    lw x3, 4(x1)
    beq x2,x3,_loop

    lw x3, 0(x1)
    
    
    slti x0, x0, -256 # this is the magic instruction to end the simulation

