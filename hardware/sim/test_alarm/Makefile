VHDL_SOURCES += ../../hdl/alarm.vhd ../../config/digitalnoise/constants.vhd
TOPLEVEL = alarm
MODULE = test_alarm

SIM_ARGS += -gRAND_WIDTH=32

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
