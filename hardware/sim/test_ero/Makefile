ifeq ($(TOPLEVEL_LANG),vhdl)
  VHDL_SOURCES += ../../hdl/vhdl/ptrng/ero.vhd ../../hdl/vhdl/ptrng/clkdivider.vhd
else
  VERILOG_SOURCES += ../../hdl/verilog/ptrng/ero.v ../../hdl/verilog/ptrng/clkdivider.v
endif

TOPLEVEL = ero
MODULE = test_ero

REG_WIDTH ?= 32

ifeq ($(TOPLEVEL_LANG),vhdl)
  SIM_ARGS += -gREG_WIDTH=$(REG_WIDTH)
else
  VERILOG_INCLUDE_DIRS += sim_build/
  COMPILE_ARGS += -P ero.REG_WIDTH=$(REG_WIDTH)
endif

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
