.section .text
.globl _start
_start:
    lui x1, 0x70006

    la x3, _INT_1 
    sw x3, 4(x1) #store INT_1 into IVT

    la x3, _INT_2 
    sw x3, 8(x1) #store INT_1 into IVT

    la x3, _INT_3 
    sw x3, 12(x1) #store INT_1 into IVT

    la x3, _INT_4 
    sw x3, 16(x1) #store INT_1 into IVT

    la x3, _INT_5 
    sw x3, 20(x1) #store INT_1 into IVT

    la x3, _INT_6 
    sw x3, 24(x1) #store INT_1 into IVT

    la x3, _INT_7 
    sw x3, 28(x1) #store INT_1 into IVT

    la x3, _INT_8 
    sw x3, 32(x1) #store INT_1 into IVT

    la x3, _INT_9 
    sw x3, 36(x1) #store INT_1 into IVT

    la x3, _INT_10 
    sw x3, 40(x1) #store INT_1 into IVT

    la x3, _INT_11
    sw x3, 44(x1) #store INT_1 into IVT

    la x3, _INT_12 
    sw x3, 48(x1) #store INT_1 into IVT

    la x3, _INT_13 
    sw x3, 52(x1) #store INT_1 into IVT

    la x3, _INT_14 
    sw x3, 56(x1) #store INT_1 into IVT

    la x3, _INT_15 
    sw x3, 60(x1) #store INT_1 into IVT

    la x3, _INT_16 
    sw x3, 64(x1) #store INT_1 into IVT


    lw x2, 0(x1) #load interrupt mask
    ori x2, x2,  0xFF #enable 8 interrupt line
    slli x2, x2, 8 #left shift by 8 to enable upper 8 and disable lower 8
    sw x2, 0(x1) #store interrupt mask

    xor x6, x6, x6
    addi x6, x6, 2
    
    xor x6, x6, x6
    addi x6, x6, 255
    xor x5, x5, x5

    ori x2, x2,  0xFF #enable first 8 interrupt line
    sw x2, 0(x1) #store interrupt mask

_loop:
    addi x5, x5, 1
    addi x8, x1, 0
    addi x8, x2, 0
    bne x5, x6, _loop

    
    lw x2, 0(x1) #load interrupt mask
    slti x0, x0, -256 # this is the magic instruction to end the simulation
_INT_1:
    lui x1, 0x70000
    sw x5, 0(x1)
    
    xor x5, x5, x1
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
     
    xor x1, x1, x1
    xor x2, x2, x2
    lui x1, 0x70000
    lw x5, 0(x1)
    mret
    
_INT_2:
    lui x1, 0x70000
    sw x6, 0(x1)
    
    xor x6, x6, x1
    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1
_loop_3:
    addi x1, x1, 1
    bne x1, x2, _loop_3
     
    xor x1, x1, x1
    xor x2, x2, x2
    lui x1, 0x70000
    lw x6, 0(x1)
    mret 

_INT_3:
    lui x1, 0x70000
    sw x6, 0(x1)
    
    xor x6, x6, x1
    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1
_loop_4:
    addi x1, x1, 1
    bne x1, x2, _loop_4
     
    xor x1, x1, x1
    xor x2, x2, x2
    lui x1, 0x70000
    lw x6, 0(x1)
    mret 

_INT_4:
    lui x1, 0x70000
    sw x6, 0(x1)
    
    xor x6, x6, x1
    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1

    lui x1, 0x70000
    lw x6, 0(x1)
    mret

_INT_5:
    lui x1, 0x70000
    sw x6, 0(x1)
    
    xor x6, x6, x1
    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1
    
    lui x1, 0x70000
    lw x6, 0(x1)
    mret

_INT_6:
    lui x1, 0x70000
    sw x6, 0(x1)
    
    xor x6, x6, x1
    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1
    
    lui x1, 0x70000
    lw x6, 0(x1)
    mret

_INT_7:
    lui x1, 0x70000
    sw x6, 0(x1)
    
    xor x6, x6, x1
    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1
    
    lui x1, 0x70000
    lw x6, 0(x1)
    mret

_INT_8:
    lui x1, 0x70000
    sw x6, 0(x1)
    
    xor x6, x6, x1
    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1
    
    lui x1, 0x70000
    lw x6, 0(x1)
    mret

_INT_9:
    lui x1, 0x70000
    sw x6, 0(x1)
    
    xor x6, x6, x1
    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1
    
    lui x1, 0x70000
    lw x6, 0(x1)
    mret

_INT_10:
    lui x1, 0x70000
    sw x6, 0(x1)
    
    xor x6, x6, x1
    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1
    
    lui x1, 0x70000
    lw x6, 0(x1)
    mret

_INT_11:
    lui x1, 0x70000
    sw x6, 0(x1)
    
    xor x6, x6, x1
    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1
    
    lui x1, 0x70000
    lw x6, 0(x1)
    mret

_INT_12:
    lui x1, 0x70000
    sw x6, 0(x1)
    
    xor x6, x6, x1
    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1
    
    lui x1, 0x70000
    lw x6, 0(x1)
    mret

_INT_13:
    lui x1, 0x70000
    sw x6, 0(x1)
    
    xor x6, x6, x1
    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1
    
    lui x1, 0x70000
    lw x6, 0(x1)
    mret

_INT_14:
    lui x1, 0x70000
    sw x6, 0(x1)
    
    xor x6, x6, x1
    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1
    
    lui x1, 0x70000
    lw x6, 0(x1)
    mret

_INT_15:
    lui x1, 0x70000
    sw x6, 0(x1)
    
    xor x6, x6, x1
    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1
    
    lui x1, 0x70000
    lw x6, 0(x1)
    mret

_INT_16:
    lui x1, 0x70000
    sw x6, 0(x1)
    
    xor x6, x6, x1
    xor x1, x1, x1
    addi x1, x1, 255
    ori x1, x1, 143

    xor x2, x2, x2
    addi x2, x1, 340
    ori x2, x2, 45

    xor x1, x1, x1
    
    lui x1, 0x70000
    lw x6, 0(x1)
    mret