SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

ifeq ($(SIM),ghdl)
	EXTRA_ARGS = -fsynopsys
endif

VHDL_SOURCES += ../../hdl/clkdiv.vhd

TOPLEVEL = clkdiv

MODULE = test_clkdiv

include $(shell cocotb-config --makefiles)/Makefile.sim
