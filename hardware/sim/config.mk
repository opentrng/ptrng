SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

ifeq ($(SIM), ghdl)
	EXTRA_ARGS += -fsynopsys
endif
