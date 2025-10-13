ifeq ($(TOPLEVEL_LANG),vhdl)
  VHDL_SOURCES += ../../target/common/generic/vhdl/fifo.vhd
else
  VERILOG_SOURCES += ../../target/common/generic/verilog/fifo.v
endif

TOPLEVEL = fifo
MODULE = test_fifo

DATA_WIDTH ?= 32
SIZE ?= 8
ALMOST_EMPTY_SIZE ?= 2
ALMOST_FULL_SIZE ?= 6

ifeq ($(TOPLEVEL_LANG),vhdl)
  SIM_ARGS += -gDATA_WIDTH=$(DATA_WIDTH) -gSIZE=$(SIZE) -gALMOST_EMPTY_SIZE=$(ALMOST_EMPTY_SIZE) -gALMOST_FULL_SIZE=$(ALMOST_FULL_SIZE)
else
  VERILOG_INCLUDE_DIRS += sim_build/
  COMPILE_ARGS += -P fifo.DATA_WIDTH=$(DATA_WIDTH) -P fifo.SIZE=$(SIZE) -P fifo.ALMOST_EMPTY_SIZE=$(ALMOST_EMPTY_SIZE) -P fifo.ALMOST_FULL_SIZE=$(ALMOST_FULL_SIZE)
endif

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
