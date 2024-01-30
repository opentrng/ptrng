SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

ifeq ($(SIM), ghdl)
	EXTRA_ARGS += -fsynopsys
	EXTRA_ARGS += --std=08
endif

SIM_ARGS += --vcd=waves.vcd

export PYTHONPATH := $(PWD)/../../../emulator:$(PYTHONPATH)
