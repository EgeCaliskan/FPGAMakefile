DESIGN = 1

JSON_DIR = ../JSON
MODULE_DIR = ../Modules
TESTBENCH_DIR = ../Testbenches
CONSTRAINT_DIR = ../Constraints
DIAGRAM_DIR = ../Diagrams

ifeq ($(DESIGN), 1)
	name :=
	sources :=
endif
SOURCES_LOC = $(addprefix $(MODULE_DIR)/, $(sources))
pack.fs : $(JSON_DIR)/$(name)_pnr.json $(MODULE_DIR)/$(name).sv $(CONSTRAINT_DIR)/$(name).cst
	gowin_pack -d GW2A-18C -o pack.fs $(JSON_DIR)/$(name)_pnr.json
	

$(JSON_DIR)/$(name)_pnr.json : $(JSON_DIR)/$(name).json $(CONSTRAINT_DIR)/$(name).cst
	nextpnr-himbaechel --json $(JSON_DIR)/$(name).json \
	--write $(JSON_DIR)/$(name)_pnr.json \
	--device "GW2AR-LV18QN88C8/I7"  \
	--vopt cst=$(CONSTRAINT_DIR)/$(name).cst \
	--vopt family="GW2A-18C"

$(JSON_DIR)/$(name).json : $(SOURCES_LOC)
	yosys -D LEDS_NR=6 -p "read_verilog -sv $(SOURCES_LOC); synth_gowin -top $(name) -json $(JSON_DIR)/$(name).json -family gw2a"

load:
	openFPGALoader -b tangnano20k pack.fs

test:
	iverilog -g2012 -o TB.vvp $(TESTBENCH_DIR)/$(name)_tb.sv $(SOURCES_LOC)
	vvp TB.vvp 2>&1 | less

verify:
	verilator --sv --lint-only $(TESTBENCH_DIR)/$(name)_tb.sv $(SOURCES_LOC) 2>&1 | less

dir:
	mkdir $(JSON_DIR) $(MODULE_DIR) $(TESTBENCH_DIR) $(CONSTRAINT_DIR) $(DIAGRAM_DIR)

make sync_makefile:
	cp ./makefile ~/Projects/IntroFPGA/makefile
