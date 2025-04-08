# Define ANSI Color Escape Codes
BOLD='\033[1m'
RED='\033[1;31m'
GREEN='\033[1;$(SRAM_SP2_CFG_BITS)m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m' # Reset text attributes to default

include rf_2p_cfg.mk
include rf_sp_cfg.mk
include rom_cfg.mk
include sram_dp_cfg.mk
include sram_sp_cfg.mk

RF_2P_BIN_PATH   := $(PWD)/rf_2p_hde_svt_rvt_hvt/bin/rf_2p_hde_svt_rvt_hvt
RF_SP_BIN_PATH   := $(PWD)/rf_sp_hdd_svt_rvt_hvt/bin/rf_sp_hdd_svt_rvt_hvt
ROM_BIN_PATH     := $(PWD)/rom_via_hde_hvt_rvt_hvt/bin/rom_via_hde_hvt_rvt_hvt
SRAM_DP_BIN_PATH := $(PWD)/sram_dp_hdc_svt_rvt_hvt/bin/sram_dp_hdc_svt_rvt_hvt
SRAM_SP_BIN_PATH := $(PWD)/sram_sp_hdc_svt_rvt_hvt/bin/sram_sp_hdc_svt_rvt_hvt

.PHONY: info
info:
	@echo -e ${GREEN}ARM MEMORY COMPILER FLOW!${RESET}
	@echo -e 
	@echo -e ${GREEN}Configure settings in cfg.mk${RESET}
	@echo -e 
	@echo -e ${GREEN}Run: make sram_sp${RESET}

.PHONY: rf_2p
rf_2p:
# Create when needed

.PHONY: rf_sp
rf_sp:
# Create when needed

.PHONY: rom
rom:
# Create when needed

.PHONY: sram_dp
sram_dp:
# Create when needed

.PHONY: sram_sp
sram_sp:
	@mkdir -p output/

# Make PostScript Datasheet
	@cd output && $(SRAM_SP_BIN_PATH) postscript \
		-instname $(SRAM_SP1_CFG_INSTNAME) \
		-words $(SRAM_SP1_CFG_WORDS) \
		-bits $(SRAM_SP1_CFG_BITS) \
		-frequency $(SRAM_SP1_CFG_FREQUENCY) \
		-mux $(SRAM_SP1_CFG_MUX) \
		-pipeline off \
		-write_mask off \
		-wp_size 8 \
		-write_thru off \
		-top_layer "m5-m9" \
		-power_type otc \
		-redundancy off \
		-rcols 2 \
		-rrows 2 \
		-bmux off \
		-ser none \
		-back_biasing off \
		-power_gating off \
		-retention on \
		-ema on \
		-atf off \
		-cust_comment "" \
		-bus_notation on \
		-left_bus_delim "[" \
		-right_bus_delim "]" \
		-pwr_gnd_rename "VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE" \
		-prefix "" \
		-name_case upper \
		-check_instname off \
		-diodes on \
		-drive 6 \
		-dnw off \
		-asvm on \
		-corners tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

	@cd output && $(SRAM_SP_BIN_PATH) postscript \
		-instname $(SRAM_SP2_CFG_INSTNAME) \
		-words $(SRAM_SP2_CFG_WORDS) \
		-bits $(SRAM_SP2_CFG_BITS) \
		-frequency $(SRAM_SP2_CFG_FREQUENCY) \
		-mux $(SRAM_SP2_CFG_MUX) \
		-pipeline off \
		-write_mask on \
		-wp_size $(SRAM_SP2_CFG_MASK_SIZE) \
		-write_thru off \
		-top_layer "m5-m9" \
		-power_type otc \
		-redundancy off \
		-rcols 2 \
		-rrows 2 \
		-bmux off \
		-ser none \
		-back_biasing off \
		-power_gating off \
		-retention on \
		-ema on \
		-atf off \
		-cust_comment "" \
		-bus_notation on \
		-left_bus_delim "[" \
		-right_bus_delim "]" \
		-pwr_gnd_rename "VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE" \
		-prefix "" \
		-name_case upper \
		-check_instname off \
		-diodes on \
		-drive 6 \
		-dnw off \
		-asvm on \
		-corners tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

# Make ASCII Datatable
	@cd output && $(SRAM_SP_BIN_PATH) ascii \
		-instname $(SRAM_SP1_CFG_INSTNAME) \
		-words $(SRAM_SP1_CFG_WORDS) \
		-bits $(SRAM_SP1_CFG_BITS) \
		-frequency $(SRAM_SP1_CFG_FREQUENCY) \
		-mux $(SRAM_SP1_CFG_MUX) \
		-pipeline off \
		-write_mask off \
		-wp_size 8 \
		-write_thru off \
		-top_layer "m5-m9" \
		-power_type otc \
		-redundancy off \
		-rcols 2 \
		-rrows 2 \
		-bmux off \
		-ser none \
		-back_biasing off \
		-power_gating off \
		-retention on \
		-ema on \
		-atf off \
		-cust_comment "" \
		-bus_notation on \
		-left_bus_delim "[" \
		-right_bus_delim "]" \
		-pwr_gnd_rename "VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE" \
		-prefix "" \
		-name_case upper \
		-check_instname off \
		-diodes on \
		-drive 6 \
		-dnw off \
		-asvm on \
		-corners tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

	@cd output && $(SRAM_SP_BIN_PATH) ascii \
		-instname $(SRAM_SP2_CFG_INSTNAME) \
		-words $(SRAM_SP2_CFG_WORDS) \
		-bits $(SRAM_SP2_CFG_BITS) \
		-frequency $(SRAM_SP2_CFG_FREQUENCY) \
		-mux $(SRAM_SP2_CFG_MUX) \
		-pipeline off \
		-write_mask on \
		-wp_size $(SRAM_SP2_CFG_MASK_SIZE) \
		-write_thru off \
		-top_layer "m5-m9" \
		-power_type otc \
		-redundancy off \
		-rcols 2 \
		-rrows 2 \
		-bmux off \
		-ser none \
		-back_biasing off \
		-power_gating off \
		-retention on \
		-ema on \
		-atf off \
		-cust_comment "" \
		-bus_notation on \
		-left_bus_delim "[" \
		-right_bus_delim "]" \
		-pwr_gnd_rename "VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE" \
		-prefix "" \
		-name_case upper \
		-check_instname off \
		-diodes on \
		-drive 6 \
		-dnw off \
		-asvm on \
		-corners tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

# Make Verilog Model
	@cd output && $(SRAM_SP_BIN_PATH) verilog \
		-instname $(SRAM_SP1_CFG_INSTNAME) \
		-words $(SRAM_SP1_CFG_WORDS) \
		-bits $(SRAM_SP1_CFG_BITS) \
		-frequency $(SRAM_SP1_CFG_FREQUENCY) \
		-mux $(SRAM_SP1_CFG_MUX) \
		-pipeline off \
		-write_mask off \
		-wp_size 8 \
		-write_thru off \
		-top_layer "m5-m9" \
		-power_type otc \
		-redundancy off \
		-rcols 2 \
		-rrows 2 \
		-bmux off \
		-ser none \
		-back_biasing off \
		-power_gating off \
		-retention on \
		-ema on \
		-atf off \
		-cust_comment "" \
		-bus_notation on \
		-left_bus_delim "[" \
		-right_bus_delim "]" \
		-pwr_gnd_rename "VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE" \
		-prefix "" \
		-name_case upper \
		-check_instname off \
		-diodes on \
		-drive 6 \
		-dnw off \
		-asvm on \
		-corners tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

	@cd output && $(SRAM_SP_BIN_PATH) verilog \
		-instname $(SRAM_SP2_CFG_INSTNAME) \
		-words $(SRAM_SP2_CFG_WORDS) \
		-bits $(SRAM_SP2_CFG_BITS) \
		-frequency $(SRAM_SP2_CFG_FREQUENCY) \
		-mux $(SRAM_SP2_CFG_MUX) \
		-pipeline off \
		-write_mask on \
		-wp_size $(SRAM_SP2_CFG_MASK_SIZE) \
		-write_thru off \
		-top_layer m5-m9 \
		-power_type otc \
		-redundancy off \
		-rcols 2 \
		-rrows 2 \
		-bmux off \
		-ser none \
		-back_biasing off \
		-power_gating off \
		-retention on \
		-ema on \
		-atf off \
		-cust_comment "" \
		-bus_notation on \
		-left_bus_delim "[" \
		-right_bus_delim "]" \
		-pwr_gnd_rename "VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE" \
		-prefix "" \
		-name_case upper \
		-check_instname off \
		-diodes on \
		-drive 6 \
		-dnw off \
		-asvm on \
		-corners tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

# Make Synopsys Model
	@cd output && $(SRAM_SP_BIN_PATH) synopsys \
		-instname $(SRAM_SP1_CFG_INSTNAME) \
		-words $(SRAM_SP1_CFG_WORDS) \
		-bits $(SRAM_SP1_CFG_BITS) \
		-frequency $(SRAM_SP1_CFG_FREQUENCY) \
		-mux $(SRAM_SP1_CFG_MUX) \
		-pipeline off \
		-write_mask off \
		-wp_size 8 \
		-write_thru off \
		-top_layer "m5-m9" \
		-power_type otc \
		-redundancy off \
		-rcols 2 \
		-rrows 2 \
		-bmux off \
		-ser none \
		-back_biasing off \
		-power_gating off \
		-retention on \
		-ema on \
		-atf off \
		-cust_comment "" \
		-bus_notation on \
		-left_bus_delim "[" \
		-right_bus_delim "]" \
		-pwr_gnd_rename "VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE" \
		-prefix "" \
		-name_case upper \
		-check_instname off \
		-diodes on \
		-drive 6 \
		-dnw off \
		-asvm on \
		-libname $(SRAM_SP1_CFG_INSTNAME) -nldm on -ccs off -ecsm off -corners tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

	@cd output && $(SRAM_SP_BIN_PATH) synopsys \
		-instname $(SRAM_SP2_CFG_INSTNAME) \
		-words $(SRAM_SP2_CFG_WORDS) \
		-bits $(SRAM_SP2_CFG_BITS) \
		-frequency $(SRAM_SP2_CFG_FREQUENCY) \
		-mux $(SRAM_SP2_CFG_MUX) \
		-pipeline off \
		-write_mask on \
		-wp_size $(SRAM_SP2_CFG_MASK_SIZE) \
		-write_thru off \
		-top_layer "m5-m9" \
		-power_type otc \
		-redundancy off \
		-rcols 2 \
		-rrows 2 \
		-bmux off \
		-ser none \
		-back_biasing off \
		-power_gating off \
		-retention on \
		-ema on \
		-atf off \
		-cust_comment "" \
		-bus_notation on \
		-left_bus_delim "[" \
		-right_bus_delim "]" \
		-pwr_gnd_rename "VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE" \
		-prefix "" \
		-name_case upper \
		-check_instname off \
		-diodes on \
		-drive 6 \
		-dnw off \
		-asvm on \
		-libname $(SRAM_SP2_CFG_INSTNAME) -nldm on -ccs off -ecsm off -corners tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

# Make VCLEF Footprint
	@cd output && $(SRAM_SP_BIN_PATH) vclef-fp \
		-instname $(SRAM_SP1_CFG_INSTNAME) \
		-words $(SRAM_SP1_CFG_WORDS) \
		-bits $(SRAM_SP1_CFG_BITS) \
		-frequency $(SRAM_SP1_CFG_FREQUENCY) \
		-mux $(SRAM_SP1_CFG_MUX) \
		-pipeline off \
		-write_mask off \
		-wp_size 8 \
		-write_thru off \
		-top_layer "m5-m9" \
		-power_type otc \
		-redundancy off \
		-rcols 2 \
		-rrows 2 \
		-bmux off \
		-ser none \
		-back_biasing off \
		-power_gating off \
		-retention on \
		-ema on \
		-atf off \
		-cust_comment "" \
		-bus_notation on \
		-left_bus_delim "[" \
		-right_bus_delim "]" \
		-pwr_gnd_rename "VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE" \
		-prefix "" \
		-name_case upper \
		-check_instname off \
		-diodes on \
		-drive 6 \
		-dnw off \
		-asvm on \
		-site_def off -corners tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

	@cd output && $(SRAM_SP_BIN_PATH) vclef-fp \
		-instname $(SRAM_SP2_CFG_INSTNAME) \
		-words $(SRAM_SP2_CFG_WORDS) \
		-bits $(SRAM_SP2_CFG_BITS) \
		-frequency $(SRAM_SP2_CFG_FREQUENCY) \
		-mux $(SRAM_SP2_CFG_MUX) \
		-pipeline off \
		-write_mask on \
		-wp_size $(SRAM_SP2_CFG_MASK_SIZE) \
		-write_thru off \
		-top_layer m5-m9 \
		-power_type otc \
		-redundancy off \
		-rcols 2 \
		-rrows 2 \
		-bmux off \
		-ser none \
		-back_biasing off \
		-power_gating off \
		-retention on \
		-ema on \
		-atf off \
		-cust_comment "" \
		-bus_notation on \
		-left_bus_delim "[" \
		-right_bus_delim "]" \
		-pwr_gnd_rename "VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE" \
		-prefix "" \
		-name_case upper \
		-check_instname off \
		-diodes on \
		-drive 6 \
		-dnw off \
		-asvm on \
		-site_def off \
		-corners tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

# Make GDSII Layout
	@cd output && $(SRAM_SP_BIN_PATH) gds2 \
		-instname $(SRAM_SP1_CFG_INSTNAME) \
		-words $(SRAM_SP1_CFG_WORDS) \
		-bits $(SRAM_SP1_CFG_BITS) \
		-frequency $(SRAM_SP1_CFG_FREQUENCY) \
		-mux $(SRAM_SP1_CFG_MUX) \
		-pipeline off \
		-write_mask off \
		-wp_size 8 \
		-write_thru off \
		-top_layer "m5-m9" \
		-power_type otc \
		-redundancy off \
		-rcols 2 \
		-rrows 2 \
		-bmux off \
		-ser none \
		-back_biasing off \
		-power_gating off \
		-retention on \
		-ema on \
		-atf off \
		-cust_comment "" \
		-bus_notation on \
		-left_bus_delim "[" \
		-right_bus_delim "]" \
		-pwr_gnd_rename "VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE" \
		-prefix "" \
		-name_case upper \
		-check_instname off \
		-diodes on \
		-drive 6 \
		-dnw off \
		-asvm on \
		-corners tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

	@cd output && $(SRAM_SP_BIN_PATH) gds2 \
		-instname $(SRAM_SP2_CFG_INSTNAME) \
		-words $(SRAM_SP2_CFG_WORDS) \
		-bits $(SRAM_SP2_CFG_BITS) \
		-frequency $(SRAM_SP2_CFG_FREQUENCY) \
		-mux $(SRAM_SP2_CFG_MUX) \
		-pipeline off \
		-write_mask on \
		-wp_size $(SRAM_SP2_CFG_MASK_SIZE) \
		-write_thru off \
		-top_layer "m5-m9" \
		-power_type otc \
		-redundancy off \
		-rcols 2 \
		-rrows 2 \
		-bmux off \
		-ser none \
		-back_biasing off \
		-power_gating off \
		-retention on \
		-ema on \
		-atf off \
		-cust_comment "" \
		-bus_notation on \
		-left_bus_delim "[" \
		-right_bus_delim "]" \
		-pwr_gnd_rename "VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE" \
		-prefix "" \
		-name_case upper \
		-check_instname off \
		-diodes on \
		-drive 6 \
		-dnw off \
		-asvm on \
		-corners tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

# Make LVS Netlist
	@cd output && $(SRAM_SP_BIN_PATH) lvs \
		-instname $(SRAM_SP1_CFG_INSTNAME) \
		-words $(SRAM_SP1_CFG_WORDS) \
		-bits $(SRAM_SP1_CFG_BITS) \
		-frequency $(SRAM_SP1_CFG_FREQUENCY) \
		-mux $(SRAM_SP1_CFG_MUX) \
		-pipeline off \
		-write_mask off \
		-wp_size 8 \
		-write_thru off \
		-top_layer "m5-m9" \
		-power_type otc \
		-redundancy off \
		-rcols 2 \
		-rrows 2 \
		-bmux off \
		-ser none \
		-back_biasing off \
		-power_gating off \
		-retention on \
		-ema on \
		-atf off \
		-cust_comment "" \
		-bus_notation on \
		-left_bus_delim "[" \
		-right_bus_delim "]" \
		-pwr_gnd_rename "VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE" \
		-prefix "" \
		-name_case upper \
		-check_instname off \
		-diodes on \
		-drive 6 \
		-dnw off \
		-asvm on \
		-corners tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

	@cd output && $(SRAM_SP_BIN_PATH) lvs \
		-instname $(SRAM_SP2_CFG_INSTNAME) \
		-words $(SRAM_SP2_CFG_WORDS) \
		-bits $(SRAM_SP2_CFG_BITS) \
		-frequency $(SRAM_SP2_CFG_FREQUENCY) \
		-mux $(SRAM_SP2_CFG_MUX) \
		-pipeline off \
		-write_mask on \
		-wp_size $(SRAM_SP2_CFG_MASK_SIZE) \
		-write_thru off \
		-top_layer "m5-m9" \
		-power_type otc \
		-redundancy off \
		-rcols 2 \
		-rrows 2 \
		-bmux off \
		-ser none \
		-back_biasing off \
		-power_gating off \
		-retention on \
		-ema on \
		-atf off \
		-cust_comment "" \
		-bus_notation on \
		-left_bus_delim "[" \
		-right_bus_delim "]" \
		-pwr_gnd_rename "VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE" \
		-prefix "" \
		-name_case upper \
		-check_instname off \
		-diodes on \
		-drive 6 \
		-dnw off \
		-asvm on \
		-corners tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

# Make TetraMax Model
	@cd output && $(SRAM_SP_BIN_PATH) tmax \
		-instname $(SRAM_SP1_CFG_INSTNAME) \
		-words $(SRAM_SP1_CFG_WORDS) \
		-bits $(SRAM_SP1_CFG_BITS) \
		-frequency $(SRAM_SP1_CFG_FREQUENCY) \
		-mux $(SRAM_SP1_CFG_MUX) \
		-pipeline off \
		-write_mask off \
		-wp_size 8 \
		-write_thru off \
		-top_layer "m5-m9" \
		-power_type otc \
		-redundancy off \
		-rcols 2 \
		-rrows 2 \
		-bmux off \
		-ser none \
		-back_biasing off \
		-power_gating off \
		-retention on \
		-ema on \
		-atf off \
		-cust_comment "" \
		-bus_notation on \
		-left_bus_delim "[" \
		-right_bus_delim "]" \
		-pwr_gnd_rename "VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE" \
		-prefix "" \
		-name_case upper \
		-check_instname off \
		-diodes on \
		-drive 6 \
		-dnw off \
		-asvm on \
		-corners tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

	@cd output && $(SRAM_SP_BIN_PATH) tmax \
		-instname $(SRAM_SP2_CFG_INSTNAME) \
		-words $(SRAM_SP2_CFG_WORDS) \
		-bits $(SRAM_SP2_CFG_BITS) \
		-frequency $(SRAM_SP2_CFG_FREQUENCY) \
		-mux $(SRAM_SP2_CFG_MUX) \
		-pipeline off \
		-write_mask on \
		-wp_size $(SRAM_SP2_CFG_MASK_SIZE) \
		-write_thru off \
		-top_layer "m5-m9" \
		-power_type otc \
		-redundancy off \
		-rcols 2 \
		-rrows 2 \
		-bmux off \
		-ser none \
		-back_biasing off \
		-power_gating off \
		-retention on \
		-ema on \
		-atf off \
		-cust_comment "" \
		-bus_notation on \
		-left_bus_delim "[" \
		-right_bus_delim "]" \
		-pwr_gnd_rename "VDDPE:VDDPE,VDDCE:VDDCE,VSSE:VSSE" \
		-prefix "" \
		-name_case upper \
		-check_instname off \
		-diodes on \
		-drive 6 \
		-dnw off \
		-asvm on \
		-corners tt_1p00v_1p00v_25c,ss_0p90v_0p90v_m40c,ss_0p90v_0p90v_125c,ff_1p10v_1p10v_m40c,ff_1p10v_1p10v_125c,ff_1p10v_1p10v_0c

# Create Synopsys Database Files from Liberty Files
	@cd output && lc_shell -batch -f ../lc_convert.tcl

.PHONY: clean
clean:
	rm -rf output