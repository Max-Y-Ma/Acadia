# Simulation Instructions

## Before simulation, compile SRAM
Navigate to ```<repo>/digital/chip/memory``` and run
> ```make sram_sp```

## Testcode 
Located in ```<repo>/digital/chip/testcode/soc```. ```/benchmarks``` contains the SP24 ECE411 competition test cases, ```/src``` contains our directed tests.

## Simulate core running a c/asm program
Generate binaries for simulation. Program can be .c, or .s file. Outputs .elf to ```bin/<progname>.elf``` and .lst flash image to ```sim/memory_flash.lst```.
>```make compile SPIKE=1 PROG=<Path to program>```

Run .elf through RISC-V Golden model, creates trace file ```sim/spike.log```
>```make spike ELF=<path to elf>```

Run .elf through our processor. memory_flash.lst is loaded into flash model, design is reset, then run. Ouputs trace file to ```sim/commit.log```. Will output sim failed due to some warnings. Sim actually fails when you see RVFI error or spike mismatches (next step).
>```make vc DIR=soc```

Check if core trace matches golden model.
>```diff -s sim/commit.log sim/spike.log```

View simulation trace using verdi
>```make verdi```

Example test (run in ```<repo>/digital/sim```)
```
make clean
make compile SPIKE=1 PROG=../chip/testcode/soc/src/soc.s
make spike ELF=bin/soc.elf
make vc DIR=soc
diff -s sim/commit.log sim/spike.log
```

## Auto run test script
```autotest.py``` will run all programs in ```testcases.txt```. For ```testcases.txt``` put one test program per line, use relative path to this directory. If the program uses peripherals, add " nospike" after the path to tell the autotest script to not run spike on it since spike doesn't simulate peripherals.

To run:
>```python3 autotest.py```