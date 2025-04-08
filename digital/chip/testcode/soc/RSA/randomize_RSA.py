import random
random.seed(7892347869324)

def start_RSA():
    inital_instr = "lui x1, 0x70008"
    instr_list = []
    instr_list.append(inital_instr)

    for i in range(3):
        first  = "xor x2, x2, x2"
        instr_list.append(first)

        second =  "lui x2, " + str(random.randrange(0, 1048500))
        instr_list.append(second)

        third  = "addi x2, x2, " + str(random.randrange(0, 2047)) 
        instr_list.append(third)

        fourth = "sw x2," + str(i*4) + "(x1)"
        instr_list.append(fourth)
        

    last = "sw x2, 12(x1)"
    instr_list.append(last)

    return instr_list


def reset_reg_instr(reg_num):
  return f"xor x{reg_num}, x{reg_num}, x{reg_num}\n"

def reg_load_val(reg_num, reg_val):
  val_upper = reg_val >> 12
  val_lower = reg_val & 0x7FF
  lui_instr = f"lui x{reg_num}, {val_upper}\n"
  add_instr = f"addi x{reg_num}, x{reg_num}, {val_lower}\n"
  return lui_instr + add_instr

def __main__():
  f = open("load_store_test.s", "w")

  # Add headers and stuff to the top
  f.write('''load_store_test.s:
.align 4
.section .text
.globl _start
_start:\n
''')

  num_tests = 5000


  for i in range(num_tests):
    store_instrs = ["sw", "sb", "sh"]
    load_instrs = ["lb", "lh", "lw", "lbu", "lhu"]

    # Generate random registers
    rand_rs1 = random.randint(0, 31)
    rand_rs2 = abs(31 - rand_rs1)
    rand_rd  = random.randint(0, 31)

    # Generate Random reg address into the register
    f.write(reset_reg_instr(rand_rs1))
    # Spike only allows between these two addresses
    rand_addr = random.randint(0x60000000, 0x80000000)

    # Generate random value to store
    f.write(reset_reg_instr(rand_rs2))
    rand_val = random.randint(0, (2**32 - 1))
    f.write(reg_load_val(rand_rs2, rand_val))

    # Generate random immediate offset
    rand_offset_1 = random.randint(0, 2**11 - 1)
    rand_offset_2 = rand_offset_1 & (~1)
    rand_offset_4 = rand_offset_1 & (~3)

    # Run all store instructions on this address
    f.write(reg_load_val(rand_rs1, rand_addr & (~0)))
    f.write(f'sb  x{rand_rs2}, {rand_offset_1}(x{rand_rs1})\n')
    f.write(reg_load_val(rand_rs1, rand_addr & (~1)))
    f.write(f'sh  x{rand_rs2}, {rand_offset_2}(x{rand_rs1})\n')
    f.write(reg_load_val(rand_rs1, rand_addr & (~3)))
    f.write(f'sw  x{rand_rs2}, {rand_offset_4}(x{rand_rs1})\n')

    # Run all load instructions on this address
    f.write(reg_load_val(rand_rs1, rand_addr & (~0)))
    f.write(f'lb  x{rand_rs2}, {rand_offset_1}(x{rand_rs1})\n')
    f.write(f'lbu x{rand_rs2}, {rand_offset_1}(x{rand_rs1})\n')
    f.write(reg_load_val(rand_rs1, rand_addr & (~1)))
    f.write(f'lh  x{rand_rs2}, {rand_offset_2}(x{rand_rs1})\n')
    f.write(f'lhu x{rand_rs2}, {rand_offset_2}(x{rand_rs1})\n')
    f.write(reg_load_val(rand_rs1, rand_addr & (~3)))
    f.write(f'lw  x{rand_rs2}, {rand_offset_4}(x{rand_rs1})\n')

    # Add new line for readability
    f.write('\n\n')

  # Footer for Program
  f.write('''
slti x0, x0, -256 # this is the magic instruction to end the simulation
''')


  f.close()


length_idx = random.randrange(200, 600)
f  = open("load_store_test.s", "r")
f_2 = open("new_load_store_test.s", "w")
i   = 0
j   = 0

# test_length = len(f.readlines())
# print(instr_list, length_idx)

for line in f:
#    print(line)
   f_2.write(str(line)) #rewrite entire file

   if(i == length_idx): # at random
      length_idx = random.randrange(300, 600) #generate next random insertion
      instr_list = start_RSA()
      i          = 0

      for entry in instr_list:
         f_2.write(f"{entry}\n")

      # if(j >= (test_length - 300)):
      #    for k in range(300):
      #       f_2.write(f"nop\n")
  
   i += 1
   j += 1

f.close()

f_2.write(f"lui x1, 0x70008\n")
f_2.write(f"_loop:\n")
f_2.write(f"lw x3, 4(x1)\n")
f_2.write(f"beq x2,x3,_loop\n")
f_2.close()


if __name__ == "__main__":
  __main__()
