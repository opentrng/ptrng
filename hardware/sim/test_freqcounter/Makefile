VHDL_SOURCES_opentrng += ../../hdl/freqcounter.vhd
TOPLEVEL = freqcounter
MODULE = test_freqcounter

SIM_ARGS += -gREG_WIDTH=24 -gN=1000

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
