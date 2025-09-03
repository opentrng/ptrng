VHDL_SOURCES += ../../hdl/ptrng/onlinetest.vhd ../../target/common/generic/fifo.vhd

TOPLEVEL = onlinetest
MODULE = test_onlinetest

SIM_ARGS += -gRAND_WIDTH=32 -gREG_WIDTH=32 -gDEPTH=128

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
