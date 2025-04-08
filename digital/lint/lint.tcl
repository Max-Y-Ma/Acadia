set_option incdir $env(DW_INC)

read_file -type verilog $env(PKG_SRCS) $env(RTL_SRCS) \
$env(MEM_SRCS) $env(CELL_SRCS) $env(DW_IP)

read_file -type awl lint.awl

set_option top $env(LINT_TOP)
set_option enable_gateslib_autocompile yes
set_option language_mode verilog
set_option enableSV09 yes
set_option enable_save_restore no
set_option mthresh 2000000000
set_option sgsyn_loop_limit 2000000000

set_option mthresh 65536

current_goal Design_Read -top $env(LINT_TOP)

current_goal lint/lint_turbo_rtl -top $env(LINT_TOP)

set_parameter checkfullstruct true

# Waive multiple simultaneous drives
waive -rules {W415}
waive -rules {STARC05-1.4.3.4}
waive -rules {W240} -file {"/software/Synopsys-2021_x86_64/syn/R-2020.09-SP4/dw/sim_ver/DW_div_seq.v"}
waive -rules {W240} -file {"/software/Synopsys-2021_x86_64/syn/R-2020.09-SP4/dw/sim_ver/DW_mult_seq.v"}
waive -rule  {SYNTH_5285} -file {"../chip/memory/output/data_sram.v"}
waive -rule  {SYNTH_5285} -file {"../chip/memory/output/icache_sram.v"}
waive -rule  {STARC05-1.3.1.3} -file {"../chip/rtl/adp/adp_cell.sv"}
waive -rule  {W216} -file {"../chip/rtl/peripherals/qspi_controller.sv"}
waive -rule  {STARC05-1.3.1.3} -file {../chip/rtl/cpu/func/multiplier.sv}
run_goal
