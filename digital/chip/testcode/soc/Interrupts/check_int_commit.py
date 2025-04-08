import sys
import subprocess

pc_count = 0
pc_mapping = {}
#generate mapping for pc to what interrupt
for j in range(1, 17):
    filename      = "spike_int_" + str(j) + ".log"

    with open(filename, "r") as f:
        for i, line in enumerate(f):
           pc_mapping[line] = j 

mismatch    = 0
start_check = 1
Int_Index   = 0
    
with open("/home/sgohil3/acadia/digital/sim/sim/int_commit.log", "r") as f:
    for i, line in enumerate(f):

        if(start_check):
            if line in pc_mapping:
                start_check = 0
                Int_Index   = pc_mapping[line]
                filename    = "spike_int_" + str(Int_Index) + ".log"
                f_2         = open(filename, "r")
            else:
                mismatch = 1
                print("[ERROR] mismatch on line: ", i+1)
                print("[ERROR] pc not found")
                continue
        
        if(line == f_2.readline()):
            if("0x30200073" in line):
                start_check = 1
            
            continue
        else:
            mismatch = 1
            print("[ERROR] mismatch on line: ", i+1, Int_Index)
            break
            