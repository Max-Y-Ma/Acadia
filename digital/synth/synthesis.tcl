if {[getenv ECE411_MIN_POWER] eq "1"} {
   set power_enable_minpower true
}

set hdlin_ff_always_sync_set_reset true
set hdlin_ff_always_async_set_reset true
set hdlin_infer_multibit default_all
set hdlin_check_no_latch true
set hdlin_while_loop_iterations 2000000000
set_host_options -max_cores 4
set_app_var report_default_significant_digits 6

# Set top-level synthesis module
set design_toplevel [getenv SYNTH_TOP]

get_license DC-Ultra-Features
get_license DC-Ultra-Opt
set SynopsysInstall [getenv "DCROOT"]
set search_path [list . \
[format "%s%s" $SynopsysInstall /libraries/syn] \
[format "%s%s" $SynopsysInstall /dw/sim_ver] \
]

# You requested %d cores. However, load on host %s is %0.2y
suppress_message UIO-231

# Design '%s' inherited license information from design '%s'.
suppress_message DDB-74
# Can't read link_library file '%s'
suppress_message UID-3
# The trip points for the library named %s differ from those in the library named %s.
suppress_message TIM-164

# There are %d potential problems in your design. Please run 'check_design' for more information.
suppress_message LINT-99
# Design '%s' contains %d high-fanout nets.
suppress_message TIM-134
# Design has unannotated black box outputs.
suppress_message PWR-428
# %s SV Assertions are ignored for synthesis since %s is not set to true.
suppress_message ELAB-33
# Ungrouping hierarchy %s before Pass 1.
suppress_message OPT-776

# Changed wire name %s to %s in module %s.
suppress_message VO-2
# Verilog 'assign' or 'tran' statements are written out.
suppress_message VO-4
# Verilog writer has added %d nets to module %s using %s as prefix.
suppress_message VO-11
# In the design %s,net '%s' is connecting multiple ports.
suppress_message UCN-1
# The replacement character (%c) is conflicting with the allowed or restricted character.
suppress_message UCN-4
# Design '%s' was renamed to '%s' to avoid a conflict with another design that has the same name but different parameters.
suppress_message LINK-17

# There are buffer or inverter cells in the clock tree. The clock tree has to be recreated after retiming.
suppress_message RTDC-47
# The design contains the following cellswhich have no influence on the design's function but cannot be removed (e.g. becauseadont_touchattributehas been setset on them). Retiming will ignore these cells in order toachieve good results: %s
suppress_message RTDC-60
# The following cells only drive asynchronous pins of sequential cells which have no timing  constraint.  Therefore  retiming will not optimize delay through them
suppress_message RTDC-115
# Unable  to  maintain nets '%s' and '%s' as separate entities.
suppress_message OPT-153
# The unannotated net '%s' is driven by a primary input port.
suppress_message PWR-416
# Datapath cell '%s' is not considered for gating.
suppress_message PWR-429
# The unannotated net '%s' is driven by a black box output.
suppress_message PWR-591
# Skipping clock gating on design %s, since there are no registers.
suppress_message PWR-806
# In design %s, there are sequential cells not driving any load.
suppress_message OPT-109

# %s DEFAULT branch of CASE statement cannot be reached.
suppress_message ELAB-311
# Netlist for always_ff block does not contain a flip-flop.
suppress_message ELAB-976
# Netlist for always_comb block is empty.
suppress_message ELAB-982
# Netlist for always_ff block is empty.
suppress_message ELAB-984
# Netlist for always block is empty.
suppress_message ELAB-985

# output port '%s' is connected directly to output port '%s'
suppress_message LINT-29
# output port '%s' is connected directly to output port '%s'
suppress_message LINT-31
# In design '%s', output port '%s' is connected directly to '%s'.
suppress_message LINT-52

# In design '%s', cell '%s' does not drive any nets.
suppress_message LINT-1
# In design '%s', net '%s' driven by pin '%s' has no loads.
suppress_message LINT-2
# '%s' is not connected to any nets
suppress_message LINT-28
# a pin on submodule '%s' is connected to logic 1 or logic 0
suppress_message LINT-32
# the same net is connected to more than one pin on submodule '%s'
suppress_message LINT-33
# The register '' is a constant and will be removed.
suppress_message OPT-1206
# The register '' will be removed.
suppress_message OPT-1207

# Set libary files
set symbol_library [list generic.sdb]
set synthetic_library [list dw_foundation.sldb]

define_design_lib WORK -path ./work
define_name_rules nameRules -restricted "!@#$%^&*()\\-" -case_insensitive

set cell_path [getenv TSMC_DB_DIR]
set search_path [concat $search_path $cell_path]

set alib_library_analysis_path ./

set verilogout_show_unconnected_pins "true"

set target_library [format "%s" [getenv TSMC_DB_FAST]]
set i_sram_library [getenv I_SRAM_DB_FAST]
set d_sram_library [getenv D_SRAM_DB_FAST]

# TODO: modify this for case $d_sram_library eq ""
if {$i_sram_library eq ""} {
  set link_library [list "*" $target_library $synthetic_library]
} else {
  set link_library [list "*" $target_library $synthetic_library $i_sram_library $d_sram_library]
  # set link_library [list "*" $target_library $synthetic_library $i_sram_library]
}

# Analyze design modules
analyze -library WORK -format sverilog [getenv PKG_SRCS]

set design_clock_pin core_ctrl0/sys_clk
set design_reset_pin core_ctrl0/sys_rst

set modules [split [getenv SYNTH_SRCS] " "]

puts [llength $modules]
set end_index [expr {[llength $modules] - 1}]
set modules [lreplace $modules $end_index $end_index]
puts [llength $modules]

foreach module $modules {
  analyze -library WORK -format sverilog "${module}"
}

elaborate $design_toplevel
current_design $design_toplevel

set_wire_load_model -name tsmc65_wl10

# Clock definition
set clk_name $design_clock_pin
set clk_period [expr [getenv ECE411_CLOCK_PERIOD_PS] / 1000.0]
create_clock -period $clk_period -name my_clk $clk_name
set_clock_uncertainty 0.3 my_clk
set_fix_hold [get_clocks my_clk]
create_clock -period $clk_period -name adp_clk adp_boundary_scan0/adp_bscan_clk
set_clock_uncertainty 0.3 adp_clk
set_fix_hold [get_clocks adp_clk]

create_generated_clock -divide_by 14 -name aclk -source core_ctrl0/sys_clk core_ctrl0/adc_clk
set_fix_hold [get_clocks aclk]

create_generated_clock -name sdc_qspi_clk -source core_ctrl0/sys_clk -divide_by 4 -invert qspi_ck_o_pin

# Set input and output delays
set_input_delay 0.5 [all_inputs] -clock my_clk
set_output_delay 0.5 [all_outputs] -clock my_clk
set_load -pin_load 2 [all_outputs]

link

eval [getenv ECE411_COMPILE_CMD]

change_names -rules verilog -hierarchy
change_names -rules nameRules -hierarchy

report_area                      > [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.area.rpt"]
report_area -hier                > [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.area_hierarchical.rpt"]
report_timing -delay max         > [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.setup.rpt"]
report_timing -delay min         > [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.hold.rpt"]
report_timing -max_path 50       > [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.timing.rpt"]
report_timing_requirement        > [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.timing_req.rpt"]
report_constraint                > [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.constraint.rpt"]
report_attribute                 > [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.attribute.rpt"]
report_constraint -all_violators > [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.viol.rpt"]
check_design                     > [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.check.rpt"]
report_hierarchy                 > [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.hierarchy.rpt"]
report_resources                 > [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.resources.rpt"]
report_reference                 > [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.reference.rpt"]
report_cell                      > [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.cell.rpt"]
report_power -verbose            > [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.power.rpt"]

write_sdf [format "%s%s%s%s" [getenv SYN_OUT_DIR] "/" $design_toplevel ".gate.sdf"]
write_sdc [format "%s%s%s%s" [getenv SYN_OUT_DIR] "/" $design_toplevel ".gate.sdc"]

write_file -format ddc -hierarchy -output outputs/synth.ddc
write_file -format verilog -hierarchy -output [format "outputs/%s.gate.v" $design_toplevel]

# start_gui

exit
