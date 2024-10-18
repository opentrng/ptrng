VHDL_SOURCES += ../../hdl/onlinetest.vhd
VHDL_SOURCES_extras += ../../lib/vhdl-extras/rtl/extras/fifos.vhdl ../../lib/vhdl-extras/rtl/extras/memory.vhdl ../../lib/vhdl-extras/rtl/extras/synchronizing.vhdl ../../lib/vhdl-extras/rtl/extras_2008/sizing_2008.vhdl

TOPLEVEL = onlinetest
MODULE = test_onlinetest

SIM_ARGS += -gRAND_WIDTH=32 -gDEPTH=128

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
