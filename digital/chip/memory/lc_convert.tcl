set name1 icache_sram
set db_name1 icache_sram

set name2 data_sram
set db_name2 data_sram

read_lib  [format "%s%s" $name1 "_nldm_ff_1p10v_1p10v_0c_syn.lib"]
write_lib [format "%s%s" $db_name1 "_nldm_ff_1p10v_1p10v_0c"]
read_lib  [format "%s%s" $name1 "_nldm_ff_1p10v_1p10v_125c_syn.lib"]
write_lib [format "%s%s" $db_name1 "_nldm_ff_1p10v_1p10v_125c"]
read_lib  [format "%s%s" $name1 "_nldm_ff_1p10v_1p10v_m40c_syn.lib"]
write_lib [format "%s%s" $db_name1 "_nldm_ff_1p10v_1p10v_m40c"]
read_lib  [format "%s%s" $name1 "_nldm_ss_0p90v_0p90v_125c_syn.lib"]
write_lib [format "%s%s" $db_name1 "_nldm_ss_0p90v_0p90v_125c"]
read_lib  [format "%s%s" $name1 "_nldm_ss_0p90v_0p90v_m40c_syn.lib"]
write_lib [format "%s%s" $db_name1 "_nldm_ss_0p90v_0p90v_m40c"]
read_lib  [format "%s%s" $name1 "_nldm_tt_1p00v_1p00v_25c_syn.lib"]
write_lib [format "%s%s" $db_name1 "_nldm_tt_1p00v_1p00v_25c"]

read_lib  [format "%s%s" $name2 "_nldm_ff_1p10v_1p10v_0c_syn.lib"]
write_lib [format "%s%s" $db_name2 "_nldm_ff_1p10v_1p10v_0c"]
read_lib  [format "%s%s" $name2 "_nldm_ff_1p10v_1p10v_125c_syn.lib"]
write_lib [format "%s%s" $db_name2 "_nldm_ff_1p10v_1p10v_125c"]
read_lib  [format "%s%s" $name2 "_nldm_ff_1p10v_1p10v_m40c_syn.lib"]
write_lib [format "%s%s" $db_name2 "_nldm_ff_1p10v_1p10v_m40c"]
read_lib  [format "%s%s" $name2 "_nldm_ss_0p90v_0p90v_125c_syn.lib"]
write_lib [format "%s%s" $db_name2 "_nldm_ss_0p90v_0p90v_125c"]
read_lib  [format "%s%s" $name2 "_nldm_ss_0p90v_0p90v_m40c_syn.lib"]
write_lib [format "%s%s" $db_name2 "_nldm_ss_0p90v_0p90v_m40c"]
read_lib  [format "%s%s" $name2 "_nldm_tt_1p00v_1p00v_25c_syn.lib"]
write_lib [format "%s%s" $db_name2 "_nldm_tt_1p00v_1p00v_25c"]

exit
