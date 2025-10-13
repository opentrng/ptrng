ifeq ($(TOPLEVEL_LANG),vhdl)
  VHDL_SOURCES += vhdl/murowrapper.vhd ../../hdl/vhdl/ptrng/muro.vhd ../../hdl/vhdl/ptrng/clkdivider.vhd
else
  VERILOG_SOURCES += verilog/murowrapper.v ../../hdl/verilog/ptrng/muro.v ../../hdl/verilog/ptrng/clkdivider.v
endif

TOPLEVEL = murowrapper
MODULE = test_muro

REG_WIDTH ?= 32

ifeq ($(TOPLEVEL_LANG),vhdl)
  SIM_ARGS += -gREG_WIDTH=$(REG_WIDTH)
else
  VERILOG_INCLUDE_DIRS += sim_build/
  COMPILE_ARGS += -P murowrapper.REG_WIDTH=$(REG_WIDTH)
endif

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
