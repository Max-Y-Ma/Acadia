# Custom Include for UVM
include ../Makefile.uvm

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

export CLOCK_PERIOD_PS = $(shell python3 ../synth/get_clock.py)

SHELL=/bin/bash -o pipefail
.SHELLFLAGS += -e

# Directory paths
DIGITAL_PATH := $(PWD)/../chip/digital
ANALOG_PATH  := $(PWD)/../chip/analog

# Testbench sources
PKG_SRCS  := $(shell find $(DIGITAL_PATH)/pkg -name '*.svh' -o -name '*.sv')
RTL_SRCS  := $(shell find $(DIGITAL_PATH)/rtl -name '*.sv')
VC_SRCS   := $(shell find $(DIGITAL_PATH)/tb/vc/$(DIR) -name '*.sv' -o -name '*.v')
VC_INC    := +incdir+$(DIGITAL_PATH)/tb/vc/$(DIR)
SRAM_SRCS := $(shell find $(PWD)/../sram/output -name '*.v')
DW_IP     := $(shell python3 get_dw_ip.py)
SRCS      := $(PKG_SRCS) $(RTL_SRCS) $(VC_SRCS) $(SRAM_SRCS) $(DW_IP)
TOP       := $(basename $(notdir $(shell find $(DIGITAL_PATH)/tb/vc/$(DIR) -name 'top_tb**.sv')))

# Toggle UVM
UVM_FLAGS := $(if $(TEST),$(VCS),)

# Simulator arguments
export VCS_ARCH_OVERRIDE=linux
VCS_FLAGS := -full64 -lca -sverilog -timescale=1ns/1ns -debug_acc+all -kdb \
-fsdb -suppress=LCA_FEATURES_ENABLED +incdir+$(DW)/sim_ver \
+define+DW_SUPPRESS_WARN

.PHONY: info
info:
	@echo -e ${GREEN}WELCOME TO THE CUSTOM TEST SUITE!${RESET}
	@echo -e 
	@echo -e ${GREEN}make vc DIR=... TEST=...${RESET}
	@echo -e 
	@echo -e ${GREEN}DIR is the name of your directory in 'chip/digital/tb/vc/...'${RESET}
	@echo -e ${GREEN}TEST is the name of your UVM test, UVM testbench specific${RESET}
	@echo -e 
	@echo -e ${GREEN}Example: make vc DIR=fifo TEST=fifo_test${RESET}
	@echo -e 

.PHONY: vc
vc: $(SRCS)
	@echo -e ${GREEN}Running Verification Component: $(TOP) @ /chip/digital/tb/vc/$(DIR)${RESET}
	@echo -e ${GREEN}Running UVM TEST: $(TEST)${RESET}
	mkdir -p sim
	python3 ../bin/rvfi_reference.py
	python3 set_dw_ip.py
	cd sim && vcs $(UVM_FLAGS) $(SRCS) $(VCS_FLAGS) $(VC_INC) -msg_config=../vcs_warn.config -l compile.log -top $(TOP) -o top_tb
	bash check_compile_error.sh
	rm -f sim/dump.fsdb
	python3 ../synth/get_clock.py
	export ECE411_CLOCK_PERIOD_PS=$(shell python3 ../synth/get_clock.py) ;\
	export ECE411_MEMLST=$(PWD)/sim/memory ;\
	cd sim && ./top_tb $(SIMV) -l simulation.log
	bash check_sim_error.sh

.PHONY: compile
compile: $(PROG)
	../bin/generate_memory_file.sh $(PROG)

.PHONY: compare
compare:
	@diff -s sim/commit.log sim/spike.log

.PHONY: cov
covrep: sim/top_tb.vdb
	cd sim && urg -dir top_tb.vdb

.PHONY: verdi
verdi:
	mkdir -p verdi
	cd verdi && $(VERDI_HOME)/bin/verdi -ssf $(PWD)/sim/dump.fsdb

.PHONY: spike
spike: $(ELF)
	mkdir -p sim
	spike --isa=rv32imc -m0x60000000:0x20000000 --log-commits $(ELF) |& tail -n +6 > sim/spike.log

.PHONY: interactive_spike
interactive_spike: $(ELF)
	mkdir -p sim
	spike --isa=rv32imc -m0x60000000:0x20000000 --log-commits -d $(ELF)

.PHONY: clean
clean:
	rm -rf bin sim verdi
