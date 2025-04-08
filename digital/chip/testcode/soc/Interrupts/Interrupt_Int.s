.section .text
.globl _start
_start:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop 

    nop
    nop
    nop
    nop

    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1
_loop_2:
    addi x1, x1, 1
    bne x1, x2, _loop_2
    
#    mret
    slti	x0,x0,-256