SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

ifeq ($(SIM), ghdl)
	EXTRA_ARGS += -fsynopsys
endif

SIM_ARGS=--vcd=waves.vcd

export PYTHONPATH := $(PWD)/../../../emulator:$(PYTHONPATH)
