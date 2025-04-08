import os
from os.path import exists

def replace_transistors(files):
    for file in files:
        sram_inst_name = ["data_sram", "icache_sram"]
        regf_inst_name = []
        netlist_file = open(file,"r")
        lines = netlist_file.readlines()
        out_file = []
        subcircuit = ""
        intance_name = ""
        for i,line in enumerate(lines):
            if ".SUBCKT" in line:
                subcircuit = line.split(' ')[1].strip()
                if subcircuit == file.split(".")[0] and subcircuit not in sram_inst_name and subcircuit not in regf_inst_name:
                    out_file.append(line.strip() + " VDD VSS\n")
                    print(line.strip() + " VDD VSS")
                    continue
            if "+" not in line:
                instance_name = line.split(' ')[0]
            if subcircuit == "FILLCAP64A10TR":
                if "MMP0 " in line and "l=130.0n" in line:
                    out_file.append(line.replace("l=130.0n", "l=60n"))
                    print(subcircuit, line.replace("l=130.0n", "l=60n"))
                    continue
            if subcircuit in [x + "SA8" for x in sram_inst_name]:
                if "M30 " in line and "w=150.0n" in line:
                    out_file.append("MM30 VSSE BTPSA SI VSSE nch l=6E-08 w=1.3E-07 m=1\n")
                    print(subcircuit, "MM30 VSSE BTPSA SI VSSE nch l=6E-08 w=1.3E-07 m=1")
                    continue
            #MM21 VSSE BTPSA SI VSSE nch l=6E-08 w=150.0n m=1
            if subcircuit in [x + "SA4_1B" for x in sram_inst_name]:
                if "M21 " in line and "w=150.0n" in line:
                    out_file.append("MM21 VSSE BTPSA SI VSSE nch l=0.06U w=0.13U  m=1\n")
                    print(subcircuit, "MM21 VSSE BTPSA SI VSSE nch l=0.06U w=0.13U  m=1")
                    continue
            if subcircuit in [x + "SA4" for x in sram_inst_name]:
                if "M28 " in line:
                    out_file.append("MM28 VSSE BTPSA SI VSSE nch l=6E-08 w=1.3E-07 m=1\n")
                    print(subcircuit, "MM28 VSSE BTPSA SI VSSE nch l=6E-08 w=1.3E-07 m=1")
                    continue
                if "M13 " in line or "M30 " in line or "M33 " in line:
                    x = line.split(' ')
                    for j,value in enumerate(x):
                        if "m=" in value:
                            x[j] = "m=2\n"
                    out = ' '.join(x)
                    out_file.append(out)
                    print(subcircuit, out.strip())
                    continue
                if "M27 " in line or "M29 " in line or "M34 " in line:
                    x = line.split(' ')
                    for j,value in enumerate(x):
                        if "m=" in value:
                            x[j] = "m=4\n"
                    out = ' '.join(x)
                    out_file.append(out)
                    print(subcircuit, out.strip())
                    continue
            if subcircuit in [x + "CTRLWRL" for x in regf_inst_name]:
                if "MM18 " in line and "l=130.0n" in line:
                    out_file.append("MM18 VDDPE SETGTP GTPB VDDCE pch l=60.0n w=39.2u m=1\n")
                    print(subcircuit, "MM18 VDDPE SETGTP GTPB VDDCE pch l=60.0n w=39.2u m=1")
                    continue
            # if subcircuit in [x + "CD8" for x in sram_inst_name]:
            #     if "M81 " in line and "w=2.5E-07" in line:
            #         out_file.append("MM81 VDDPE YNPASS4 YPPASS4 VDDCE pch l=0.06u =0.25u m=1\n")
            #         print(subcircuit, "MM81 VDDPE YNPASS4 YPPASS4 VDDCE pch l=0.06u =0.25u m=1")
            #         continue
            if subcircuit in [x + "CTRLSAL" for x in regf_inst_name]:
                if "MM61 " in line and "l=130.0n" in line:
                    out_file.append("MM61 VDDPE SETGTP GTPA VDDCE pch l=60.0n w=3.9E-05 m=1\n")
                    print(subcircuit, "MM61 VDDPE SETGTP GTPA VDDCE pch l=60.0n w=3.9E-05 m=1")
                    continue
            if subcircuit.startswith(tuple(sram_inst_name)):
                if "nch_lvt" in line:
                    x = line.split(' ')
                    for j,value in enumerate(x):
                        if "nch_l" in value:
                            x[j] = "nchpd_sr"
                        if "w=" in value:
                            x[j] = "w=1.4E-07"
                    out = ' '.join(x)
                    out_file.append(out)
                    print(subcircuit, out.strip())
                    continue
                if "pch_lvt" in line:
                    x = line.split(' ')
                    for j,value in enumerate(x):
                        if "pch_l" in value:
                            x[j] = "pchpu_sr"
                        if "w=" in value:
                            x[j] = "w=8E-08"
                    out = ' '.join(x)
                    out_file.append(out)
                    print(subcircuit, out.strip())
                    continue
                if "nch_na" in line:
                    x = line.split(' ')
                    for j,value in enumerate(x):
                        if "nch" in value:
                            x[j] = "nchpg_sr"
                        if "w=" in value:
                            x[j] = "w=9E-08"
                        if "l=" in value:
                            x[j] = "l=7.5E-08"
                    out = ' '.join(x)
                    out_file.append(out)
                    print(subcircuit, out.strip())
                    continue
                if "NDIO" in line:
                    x = line.split(' ')
                    for j,value in enumerate(x):
                        if "area=" in value:
                            x[j] = "area=1.024e-13"
                        if "pj=" in value:
                            x[j] = "pj=1.28e-6"
                    out = ' '.join(x)
                    out_file.append(out)
                    print(subcircuit, out.strip())
                    continue
            if subcircuit.startswith(tuple(regf_inst_name)):
                if "nch_25" in line:
                    x = line.split(' ')
                    for j,value in enumerate(x):
                        if "nch" in value:
                            x[j] = "nchpd_dpsr"
                        if "w=" in value:
                            x[j] = "w=3.15E-07"
                        if "l=" in value:
                            x[j] = "l=6.5E-08"
                    out = ' '.join(x)
                    out_file.append(out)
                    print(subcircuit, out.strip())
                    continue
                if "pch_25" in line:
                    x = line.split(' ')
                    for j,value in enumerate(x):
                        if "pch" in value:
                            x[j] = "pchpu_dpsr"
                        if "w=" in value:
                            x[j] = "w=9E-08"
                        if "l=" in value:
                            x[j] = "l=7E-08"
                    out = ' '.join(x)
                    out_file.append(out)
                    print(subcircuit, out.strip())
                    continue
                if "nch_dnw" in line:
                    x = line.split(' ')
                    for j,value in enumerate(x):
                        if "nch" in value:
                            x[j] = "nchpg_dpsr"
                        if "w=" in value:
                            x[j] = "w=1.05E-7"
                        if "l=" in value:
                            x[j] = "l=8E-08"
                    out = ' '.join(x)
                    out_file.append(out)
                    print(subcircuit, out.strip())
                    continue
                if "NDIO" in line:
                    x = line.split(' ')
                    for j,value in enumerate(x):
                        if "area=" in value:
                            x[j] = "area=5.76e-14"
                        if "pj=" in value:
                            x[j] = "pj=1.28e-6"
                    out = ' '.join(x)
                    out_file.append(out)
                    print(subcircuit, out.strip())
                    continue
            if subcircuit in sram_inst_name or subcircuit in regf_inst_name or subcircuit == file.split(".")[0]:
                if "<" in line:
                    out = line.replace('<','[')
                    out = out.replace('>',']')
                    out_file.append(out)
                    print(subcircuit, out.strip())
                    continue
            out_file.append(line)

        out_netlist_file = open("out."+file,"w")
        out_netlist_file.writelines(out_file)
        out_netlist_file.close()
        netlist_file.close()

if __name__ == "__main__":
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    os.chdir("../lvs")
    files0 = [
        "data_sram.src.net",
        "icache_sram.src.net",
        # "example_regfile.src.net",
        "core.src.net"
        # "chiptop.src.net",
        # "finished_chiptop.src.net"
    ]
    files = list(filter(exists, files0))
    replace_transistors(files)
