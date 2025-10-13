ifeq ($(TOPLEVEL_LANG),vhdl)
  VHDL_SOURCES += ../../hdl/vhdl/ptrng/freqcounter.vhd
else
  VERILOG_SOURCES += ../../hdl/verilog/ptrng/freqcounter.v
endif

TOPLEVEL = freqcounter
MODULE = test_freqcounter

REG_WIDTH ?= 24
N ?= 1000

ifeq ($(TOPLEVEL_LANG),vhdl)
  SIM_ARGS += -gREG_WIDTH=$(REG_WIDTH) -gN=$(N)
else
  VERILOG_INCLUDE_DIRS += sim_build/
  COMPILE_ARGS += -P freqcounter.REG_WIDTH=$(REG_WIDTH) -P freqcounter.N=$(N)
endif

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
