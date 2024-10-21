# Add design HDL source files to the list
set hdl_files [list \
	[list "work" [file normalize "${hardware}/hdl/clkdivider.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/bitpacker.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/ero.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/muro.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/coso.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/digitizer.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/synchronizer.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/digitalnoise.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/freqcounter.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/alarm.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/onlinetest.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/conditioner.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/ptrng.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/prefetch.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/top.vhd"]] \
]

# Add configuration files
lappend hdl_files [list "work" [file normalize "${hardware}/config/registers/regmap.vhd"]]
lappend hdl_files [list "work" [file normalize "${hardware}/config/digitalnoise/constants.vhd"]]
lappend hdl_files [list "work" [file normalize "${hardware}/config/digitalnoise/settings.vhd"]]

# Add required HDL sources files from libraries
lappend hdl_files [list "work" [file normalize "${hardware}/lib/fluart/fluart.vhdl"]]
lappend hdl_files [list "work" [file normalize "${hardware}/lib/cmd_proc/cmd_proc.vhdl"]]
lappend hdl_files [list "extras" [file normalize "${hardware}/lib/vhdl-extras/rtl/extras/synchronizing.vhdl"]]
lappend hdl_files [list "extras" [file normalize "${hardware}/lib/vhdl-extras/rtl/extras_2008/sizing_2008.vhdl"]]
lappend hdl_files [list "extras" [file normalize "${hardware}/lib/vhdl-extras/rtl/extras/memory.vhdl"]]
lappend hdl_files [list "extras" [file normalize "${hardware}/lib/vhdl-extras/rtl/extras/fifos.vhdl"]]
