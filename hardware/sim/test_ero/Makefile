VHDL_SOURCES += ../../hdl/ptrng/ero.vhd ../../hdl/ptrng/clkdivider.vhd
TOPLEVEL = ero
MODULE = test_ero

SIM_ARGS += -gREG_WIDTH=32

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
