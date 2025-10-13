ifeq ($(TOPLEVEL_LANG),vhdl)
  VHDL_SOURCES += ../../hdl/vhdl/ptrng/bitpacker.vhd
else
  VERILOG_SOURCES += ../../hdl/verilog/ptrng/bitpacker.v
endif

TOPLEVEL = bitpacker
MODULE = test_bitpacker

W ?= 32

ifeq ($(TOPLEVEL_LANG),vhdl)
  SIM_ARGS += -gW=$(W)
else
  VERILOG_INCLUDE_DIRS += sim_build/
  COMPILE_ARGS += -P bitpacker.W=$(W)
endif

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
