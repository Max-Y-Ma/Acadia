binary_width        = 4
thermometer_counter = 0

def gen_thermometer_binary(curr_depth, curr_expr):
  global thermometer_counter

  curr_expr += f"binary[{curr_depth}]"
  if (curr_depth == 0):
    print(f"thermometer[{thermometer_counter}] = " + curr_expr + ((binary_width - curr_depth - 1) * ')')  + ';')
    thermometer_counter += 1

    return
  else:
    gen_thermometer_binary(curr_depth - 1, curr_expr + ' | (')
    print(f"thermometer[{thermometer_counter}] = " + curr_expr + ((binary_width - curr_depth - 1) * ')')  + ';')
    thermometer_counter += 1
    gen_thermometer_binary(curr_depth - 1, curr_expr + ' & (')


gen_thermometer_binary(binary_width - 1, '')
