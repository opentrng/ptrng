ifeq ($(TOPLEVEL_LANG),vhdl)
  VHDL_SOURCES += ../../hdl/vhdl/ptrng/ptrng.vhd vhdl/digitalnoise_stub.vhd ../../target/common/generic/vhdl/fifo.vhd ../../hdl/vhdl/ptrng/bitpacker.vhd ../../hdl/vhdl/ptrng/alarm.vhd ../../hdl/vhdl/ptrng/onlinetest.vhd ../../hdl/vhdl/ptrng/conditioner.vhd ../../config/digitalnoise/constants.vhd ../../config/digitalnoise/settings.vhd
else
  VERILOG_SOURCES += ../../config/digitalnoise/constants.v ../../config/digitalnoise/settings.v ../../hdl/verilog/ptrng/ptrng.v verilog/digitalnoise_stub.v ../../target/common/generic/verilog/fifo.v ../../hdl/verilog/ptrng/bitpacker.v ../../hdl/verilog/ptrng/alarm.v ../../hdl/verilog/ptrng/onlinetest.v ../../hdl/verilog/ptrng/conditioner.v 
endif

TOPLEVEL = ptrng
MODULE = test_ptrng

REG_WIDTH  ?= 32
RAND_WIDTH ?= 32

ifeq ($(TOPLEVEL_LANG),vhdl)
  SIM_ARGS += -gREG_WIDTH=$(REG_WIDTH) -gRAND_WIDTH=$(RAND_WIDTH)
else
  VERILOG_INCLUDE_DIRS += sim_build/
  VERILOG_INCLUDE_DIRS += ../../config/digitalnoise/
  COMPILE_ARGS += -P ptrng.REG_WIDTH=$(REG_WIDTH) -P ptrng.RAND_WIDTH=$(RAND_WIDTH)
endif

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
