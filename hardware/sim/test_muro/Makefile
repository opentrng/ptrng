VHDL_SOURCES += murowrapper.vhd ../../hdl/muro.vhd ../../hdl/clkdivider.vhd
TOPLEVEL = murowrapper
MODULE = test_muro

SIM_ARGS += -gREG_WIDTH=32

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
