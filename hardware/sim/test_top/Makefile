VHDL_SOURCES += ../../hdl/top.vhd ../../hdl/ptrng.vhd ../../hdl/digitizer.vhd ../../hdl/digitalnoise.vhd  ../../hdl/freqcounter.vhd  ../../hdl/synchronizer.vhd  ../../hdl/prefetch.vhd ../../hdl/bitpacker.vhd ../../hdl/clkdivider.vhd ../../hdl/ero.vhd ../../hdl/muro.vhd ../../hdl/coso.vhd ../../hdl/alarm.vhd ../../hdl/onlinetest.vhd ../../hdl/conditioner.vhd
VHDL_SOURCES += ../../target/common/generic/ring.vhd
VHDL_SOURCES += ../../config/digitalnoise/constants.vhd ../../config/digitalnoise/settings.vhd ../../config/registers/regmap.vhd
VHDL_SOURCES += ../../lib/fluart/fluart.vhdl ../../lib/cmd_proc/cmd_proc.vhdl
VHDL_SOURCES_extras += ../../lib/vhdl-extras/rtl/extras/fifos.vhdl ../../lib/vhdl-extras/rtl/extras/memory.vhdl ../../lib/vhdl-extras/rtl/extras/synchronizing.vhdl ../../lib/vhdl-extras/rtl/extras_2008/sizing_2008.vhdl

TOPLEVEL = top
MODULE = test_top

include ../config.mk
include $(shell cocotb-config --makefiles)/Makefile.sim
