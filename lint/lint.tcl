read_file -type verilog $env(PKG_SRCS) $env(RTL_SRCS)
if {$env(SRAM_LIB) != ""} {
    read_file -type gateslibdb $env(SRAM_LIB)
}
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

run_goal

# help -rules STARC05-2.11.3.1
