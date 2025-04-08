.section .text
.globl _start
_start:


    # Load RSA value
    lui x1, 0x70006
    la x3, _INT_1 

    lw x2, 0(x1) #load interrupt mask
    ori x2, x2,  1 #enable first interrupt line

    sw x3, 4(x1) #store INT_1 into IVT
    sw x2, 0(x1) #return interrupt mask

    lw x4, 4(x1)#ensure that IVT properly populated
    lw x5, 0(x1) #ensure that INT_MASK was properly poulated
    
    xor x6, x6, x6
    addi x6, x6, 2
    
    xor x6, x6, x6
    addi x6, x6, 255
    xor x5, x5, x5
_loop:
    addi x5, x5, 1
    bne x5, x6, _loop

    
    lw x2, 0(x1) #load interrupt mask
    slti x0, x0, -256 # this is the magic instruction to end the simulation

_INT_1:
    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1
_loop_2:
    addi x1, x1, 1
    beq x1, x2, _loop_2
    
    mret
    
    

