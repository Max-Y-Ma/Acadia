include libs.mk

SHELL=/bin/bash -o pipefail
.SHELLFLAGS += -e

# Define ANSI Color Escape Codes
BOLD='\033[1m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m' # Reset text attributes to default

FSDB2SAIF_START = $(shell head -n1 ../sim/sim/time.txt)
FSDB2SAIF_END   = $(shell tail -n1 ../sim/sim/time.txt)

# Directory paths
DIGITAL_PATH := $(PWD)/../chip

export SYNTH_TOP := $(TOP)

# Source files
export PKG_SRCS  := $(shell find $(DIGITAL_PATH)/pkg -name '*.svh')
RTL_SRCS  := $(shell find $(DIGITAL_PATH)/rtl -name '*.sv')
CELL_SRCS := $(shell find $(DIGITAL_PATH)/stdcells -name '*.sv')
export SYNTH_SRCS := $(RTL_SRCS) $(CELL_SRCS) $(MEM_SRCS)

export REPORT_DIR  := reports
export SYN_OUT_DIR := outputs

export STD_CELL_LIB=$(FREEPDK45)/stdcells.db
$(info    VAR is $(FREEPDK45))
$(info    TOP is $(SYNTH_TOP))

.PHONY: info
info:
	@echo -e ${GREEN}WELCOME TO THE SYNTHESIZER!${RESET}
	@echo -e 
	@echo -e ${GREEN}TOP is the top level module in 'chip/digital/rtl/...'${RESET}
	@echo -e ${GREEN}Example: make synth TOP=...${RESET}
	@echo -e 

.PHONY: synth
synth: clean
	$(MAKE) outputs/synth.ddc

outputs/synth.ddc:
	mkdir -p reports outputs
	python3 get_clock.py
	python3 get_min_power.py
	python3 get_compile_cmd.py
	export ECE411_CLOCK_PERIOD_PS=$(shell python3 get_clock.py) ;\
	export ECE411_MIN_POWER=$(shell python3 get_min_power.py) ;\
	export ECE411_COMPILE_CMD="$(shell python3 get_compile_cmd.py)" ;\
	dc_shell-xg-t -64bit -f synthesis.tcl |& tee reports/synthesis.log
	rm -f  *.log
	rm -f  default.svf
	rm -rf work
	bash check_synth_error.sh $(TOP)

../sim/sim/dump.fsdb.saif: ../sim/sim/dump.fsdb
	cd ../sim/sim && fsdb2saif dump.fsdb -bt $(FSDB2SAIF_START)ps -et $(FSDB2SAIF_END)ps -s top_tb/dut

.PHONY: power
power: outputs/synth.ddc ../sim/sim/dump.fsdb.saif
	dc_shell-xg-t -64bit -f power.tcl |& tee reports/power.log

.PHONY: dv
dv:
	design_vision -f dc-gui.tcl

.PHONY: clean
clean:
	rm -f  *.log
	rm -f  default.svf
	rm -rf work
	rm -rf reports
	rm -rf outputs
