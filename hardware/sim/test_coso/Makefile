ifeq ($(TOPLEVEL_LANG),vhdl)
  VHDL_SOURCES += ../../hdl/vhdl/ptrng/coso.vhd
else
  VERILOG_SOURCES += ../../hdl/verilog/ptrng/coso.v
endif

TOPLEVEL = coso
MODULE = test_coso

DATA_WIDTH ?= 16

ifeq ($(TOPLEVEL_LANG),vhdl)
  SIM_ARGS += -gDATA_WIDTH=$(DATA_WIDTH)
else
  VERILOG_INCLUDE_DIRS += sim_build/
  COMPILE_ARGS += -P coso.DATA_WIDTH=$(DATA_WIDTH)
endif

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
