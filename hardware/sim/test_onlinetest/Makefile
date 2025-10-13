ifeq ($(TOPLEVEL_LANG),vhdl)
  VHDL_SOURCES += ../../hdl/vhdl/ptrng/onlinetest.vhd ../../target/common/generic/vhdl/fifo.vhd
else
  VERILOG_SOURCES += ../../hdl/verilog/ptrng/onlinetest.v ../../target/common/generic/verilog/fifo.v
endif

TOPLEVEL = onlinetest
MODULE = test_onlinetest

RAND_WIDTH ?= 32
REG_WIDTH ?= 32
DEPTH ?= 128

ifeq ($(TOPLEVEL_LANG),vhdl)
  SIM_ARGS += -gRAND_WIDTH=$(RAND_WIDTH) -gREG_WIDTH=$(REG_WIDTH) -gDEPTH=$(DEPTH)
else
  VERILOG_INCLUDE_DIRS += sim_build/
  COMPILE_ARGS += -P onlinetest.RAND_WIDTH=$(RAND_WIDTH) -P onlinetest.REG_WIDTH=$(REG_WIDTH) -P onlinetest.DEPTH=$(DEPTH)
endif

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
