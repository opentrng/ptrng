VHDL_SOURCES_opentrng += ../../hdl/ero.vhd ../../hdl/clkdivider.vhd
TOPLEVEL = ero
MODULE = test_ero

SIM_ARGS += -gREG_WIDTH=32

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
