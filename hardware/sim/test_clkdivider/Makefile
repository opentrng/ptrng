ifeq ($(TOPLEVEL_LANG),vhdl)
  VHDL_SOURCES += ../../hdl/vhdl/ptrng/clkdivider.vhd
else
  VERILOG_SOURCES += ../../hdl/verilog/ptrng/clkdivider.v
endif

TOPLEVEL = clkdivider
MODULE = test_clkdivider

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
