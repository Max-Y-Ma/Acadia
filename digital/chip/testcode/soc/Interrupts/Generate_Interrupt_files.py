import sys
import subprocess

pc_count = 0

for j in range(1, 17):
    filename      = "Interrupt_Int_" + str(j) + ".s"
    f             = open(filename, "w")
    write_flag    = 0
    instr_list    = []

    with open("Interrupt_Update.dis", "r") as f_og:
        for i, line in enumerate(f_og):
            #_INT_1:
            if(("<_INT_" + str(j) + ">:") in line):
                pc_count = (int(line[5:8], base=16) / 2)

    with open("Interrupt_Update.s", "r") as f_og:
        for i, line in enumerate(f_og):

            #_INT_1:
            if(("_INT_" + str(j) + ":") in line):
                print(line)
                instr_list    = []
                write_flag = 1
                continue

            #stop writing on next mret
            if(write_flag == 1 and "mret" in line):
                write_flag = 0
                instr_list.append("slti x0, x0, -256\n")
                break

            if(i < 3):
                f.write(line)
            elif(write_flag == 1):
                instr_list.append(line)

    print(pc_count)
    print(instr_list)
    
    for i in range(int(pc_count)):
        f.write("nop\n")
    
    for line in instr_list:
        f.write(line)

    f.close()        

    subprocess.call("./Compile_Interrupt_spike.sh " + str(j), shell=True)

    #strip all the nops from the spike log
    filename      = "spike_int_" + str(j) + ".log"
    with open(filename, "r") as f:
        lines = f.readlines()

    with open(filename, "w") as f:
        for line in lines:
            if("0x0001" in line):
                continue
            else:
                f.write(line)