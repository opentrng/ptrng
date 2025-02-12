VHDL_SOURCES += ../../hdl/top.vhd ../../lib/fluart/fluart.vhdl ../../lib/cmd_proc/cmd_proc.vhdl ../../config/registers/regmap.vhd
VHDL_SOURCES_opentrng += ../../hdl/ptrng.vhd ../../hdl/digitizer.vhd ../../hdl/digitalnoise.vhd  ../../hdl/freqcounter.vhd  ../../hdl/synchronizer.vhd  ../../hdl/fifo.vhd ../../hdl/bitpacker.vhd ../../hdl/clkdivider.vhd ../../hdl/ero.vhd ../../hdl/muro.vhd ../../hdl/coso.vhd ../../hdl/alarm.vhd ../../hdl/onlinetest.vhd ../../hdl/conditioner.vhd ../../target/common/generic/ring.vhd ../../config/digitalnoise/constants.vhd ../../config/digitalnoise/settings.vhd

TOPLEVEL = top
MODULE = test_top

SIM_ARGS += -gCLK_REF=100_000_000 -gFIFO_SIZE=16 -gBURST_SIZE=4

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
