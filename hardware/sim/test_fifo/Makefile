VHDL_SOURCES += ../../target/common/generic/fifo.vhd

TOPLEVEL = fifo
MODULE = test_fifo

SIM_ARGS += -gDATA_WIDTH=32 -gSIZE=8 -gALMOST_EMPTY_SIZE=2 -gALMOST_FULL_SIZE=6

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
