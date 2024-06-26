tech_name = "freepdk45"

num_rw_ports = 0
num_r_ports  = 1
num_w_ports  = 1

# 7 set bits, 25 tag bits 32 bits per target
word_size  = 20 # (at 7 set bits, we look only at 15 and under on the PC)
write_size = 20 # (24 + 32)
num_words  = 128

nominal_corner_only = True
process_corners = ["TT"]
supply_voltages = [1.0]
temperatures = [25]

netlist_only = False
route_supplies = False
check_lvsdrc = False

perimeter_pins = False

load_scales = [0.5, 1, 4]
slew_scales = [0.5, 1]

output_name = "btb_array"
output_path = f"output/{output_name}"

print_banner = False
num_threads = 4
output_extended_config = True
