VHDL_SOURCES += ../../hdl/ptrng/ptrng.vhd digitalnoise_stub.vhd ../../target/common/generic/fifo.vhd ../../hdl/ptrng/bitpacker.vhd ../../hdl/ptrng/alarm.vhd ../../hdl/ptrng/onlinetest.vhd ../../hdl/ptrng/conditioner.vhd ../../config/digitalnoise/constants.vhd ../../config/digitalnoise/settings.vhd

TOPLEVEL = ptrng
MODULE = test_ptrng

SIM_ARGS += -gREG_WIDTH=32 -gRAND_WIDTH=32

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
