SIM ?= ghdl
export TOPLEVEL_LANG := vhdl

ifeq ($(SIM), ghdl)
	EXTRA_ARGS += -fsynopsys
	EXTRA_ARGS += --std=08
	
	SIM_ARGS += --vcd=waves.vcd
else    
        WAVES = 1
endif

export PYTHONPATH := $(PWD)/..:$(PYTHONPATH)
export PYTHONPATH := $(PWD)/../../../emulator:$(PYTHONPATH)
