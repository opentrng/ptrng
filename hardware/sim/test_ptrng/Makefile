VHDL_SOURCES += ../../hdl/ptrng.vhd
VHDL_SOURCES_opentrng += digitalnoise_stub.vhd
VHDL_SOURCES_opentrng +=  ../../target/common/generic/fifo.vhd ../../hdl/bitpacker.vhd ../../hdl/alarm.vhd ../../hdl/onlinetest.vhd ../../hdl/conditioner.vhd ../../config/digitalnoise/constants.vhd ../../config/digitalnoise/settings.vhd

TOPLEVEL = ptrng
MODULE = test_ptrng

SIM_ARGS += -gREG_WIDTH=32 -gRAND_WIDTH=32

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
