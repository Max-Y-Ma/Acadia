.section .text
.globl _start
    # Refer to the RISC-V ISA Spec for the functionality of
    # the instructions in this test program.
_start:
    # Note that the comments in this file should not be taken as
    # an example of good commenting style!!  They are merely provided
    # in an effort to help you understand the assembly style.

    # Simple Compressed Ext. Test
    nop
    nop
    or x0, x0, x1

    # Misaligned Compressed Ext. Test 1
    nop
    or x0, x0, x1
    nop

    # Misaligned Compressed Ext. Test 2
    or x0, x0, x1
    nop
    nop

    # Misaligned Compressed Ext. Test 3
    nop
    nop
    nop
    nop
    
    slti x0, x0, -256 # this is the magic instruction to end the simulation
    nop
    nop
    nop
    nop
    nop