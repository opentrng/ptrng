# Add design HDL source files to the list
set hdl_files [list \
	[list "opentrng" [file normalize "${hardware}/hdl/clkdivider.vhd"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/bitpacker.vhd"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/ero.vhd"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/muro.vhd"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/coso.vhd"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/digitizer.vhd"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/synchronizer.vhd"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/digitalnoise.vhd"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/freqcounter.vhd"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/alarm.vhd"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/onlinetest.vhd"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/conditioner.vhd"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/ptrng.vhd"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/fifo.vhd"]] \
]

# Add configuration files
lappend hdl_files [list "opentrng" [file normalize "${hardware}/config/digitalnoise/constants.vhd"]]
lappend hdl_files [list "opentrng" [file normalize "${hardware}/config/digitalnoise/settings.vhd"]]

# Add opentrng top file
lappend hdl_files [list "work" [file normalize "${hardware}/hdl/top.vhd"]]

# Add required utility sources files
lappend hdl_files [list "work" [file normalize "${hardware}/config/registers/regmap.vhd"]]
lappend hdl_files [list "work" [file normalize "${hardware}/hdl/analog.vhd"]]

# Add required HDL sources files from libraries
lappend hdl_files [list "work" [file normalize "${hardware}/lib/fluart/fluart.vhdl"]]
lappend hdl_files [list "work" [file normalize "${hardware}/lib/cmd_proc/cmd_proc.vhdl"]]
