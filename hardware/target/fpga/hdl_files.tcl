# Add design HDL source files to the list
set hdl_files [list \
	[list "work" [file normalize "${hardware}/hdl/ptrng/clkdivider.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/ptrng/bitpacker.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/ptrng/ero.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/ptrng/muro.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/ptrng/coso.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/ptrng/digitizer.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/ptrng/synchronizer.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/ptrng/digitalnoise.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/ptrng/freqcounter.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/ptrng/alarm.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/ptrng/onlinetest.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/ptrng/conditioner.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/ptrng/ptrng.vhd"]] \
]

# Add configuration files
lappend hdl_files [list "work" [file normalize "${hardware}/config/digitalnoise/constants.vhd"]]
lappend hdl_files [list "work" [file normalize "${hardware}/config/digitalnoise/settings.vhd"]]

# Add required utility sources files
lappend hdl_files [list "work" [file normalize "${hardware}/target/common/generic/fifo.vhd"]]
lappend hdl_files [list "work" [file normalize "${hardware}/config/registers/regmap.vhd"]]
lappend hdl_files [list "work" [file normalize "${hardware}/hdl/analog.vhd"]]

# Add opentrng top file
lappend hdl_files [list "work" [file normalize "${hardware}/hdl/top.vhd"]]

# Add required HDL sources files from libraries
lappend hdl_files [list "work" [file normalize "${hardware}/lib/fluart/fluart.vhdl"]]
lappend hdl_files [list "work" [file normalize "${hardware}/lib/cmd_proc/cmd_proc.vhdl"]]
