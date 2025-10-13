ifeq ($(TOPLEVEL_LANG),vhdl)
  VHDL_SOURCES += ../../hdl/vhdl/ptrng/alarm.vhd ../../config/digitalnoise/constants.vhd
else
  VERILOG_SOURCES += ../../hdl/verilog/ptrng/alarm.v ../../config/digitalnoise/constants.v
endif

TOPLEVEL = alarm
MODULE = test_alarm

RAND_WIDTH ?= 32
REG_WIDTH  ?= 32

ifeq ($(TOPLEVEL_LANG),vhdl)
  SIM_ARGS += -gRAND_WIDTH=$(RAND_WIDTH) -gREG_WIDTH=$(REG_WIDTH)
else
  VERILOG_INCLUDE_DIRS += sim_build/
  COMPILE_ARGS += -P alarm.RAND_WIDTH=$(RAND_WIDTH) -P alarm.REG_WIDTH=$(REG_WIDTH)
endif

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
