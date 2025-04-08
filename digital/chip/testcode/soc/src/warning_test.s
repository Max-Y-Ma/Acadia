.section .text
.globl _start
    # Refer to the RISC-V ISA Spec for the functionality of
    # the instructions in this test program.
_start:
    # Note that the comments in this file should not be taken as
    # an example of good commenting style!!  They are merely provided
    # in an effort to help you understand the assembly style.

    slti x0, x0, -10    # Throw mismatch error to monitor
    slti x0, x0, -11    # Throw mismatch warning to monitor
    slti x0, x0, -256   #halt