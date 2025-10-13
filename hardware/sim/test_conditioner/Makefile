ifeq ($(TOPLEVEL_LANG),vhdl)
  VHDL_SOURCES += ../../hdl/vhdl/ptrng/conditioner.vhd
else
  VERILOG_SOURCES += ../../hdl/verilog/ptrng/conditioner.v
endif

TOPLEVEL = conditioner
MODULE = test_conditioner

RAND_WIDTH ?= 32

ifeq ($(TOPLEVEL_LANG),vhdl)
  SIM_ARGS += -gRAND_WIDTH=$(RAND_WIDTH)
else
  VERILOG_INCLUDE_DIRS += sim_build/
  COMPILE_ARGS += -P conditioner.RAND_WIDTH=$(RAND_WIDTH)
endif

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
