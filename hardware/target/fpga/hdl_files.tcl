# Add design HDL source files to the list
set hdl_files [list \
	[list "work" [file normalize "${hardware}/hdl/vhdl/ptrng/clkdivider.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/vhdl/ptrng/bitpacker.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/vhdl/ptrng/ero.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/vhdl/ptrng/muro.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/vhdl/ptrng/coso.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/vhdl/ptrng/digitizer.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/vhdl/ptrng/synchronizer.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/vhdl/ptrng/digitalnoise.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/vhdl/ptrng/freqcounter.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/vhdl/ptrng/alarm.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/vhdl/ptrng/onlinetest.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/vhdl/ptrng/conditioner.vhd"]] \
	[list "work" [file normalize "${hardware}/hdl/vhdl/ptrng/ptrng.vhd"]] \
]

# Add configuration files
lappend hdl_files [list "work" [file normalize "${hardware}/config/digitalnoise/constants.vhd"]]
lappend hdl_files [list "work" [file normalize "${hardware}/config/digitalnoise/settings.vhd"]]

# Add required utility sources files
lappend hdl_files [list "work" [file normalize "${hardware}/target/common/generic/vhdl/fifo.vhd"]]
lappend hdl_files [list "work" [file normalize "${hardware}/config/registers/regmap.vhd"]]
lappend hdl_files [list "work" [file normalize "${hardware}/hdl/vhdl/analog.vhd"]]

# Add opentrng top file
lappend hdl_files [list "work" [file normalize "${hardware}/hdl/vhdl/top.vhd"]]

# Add required HDL sources files from libraries
lappend hdl_files [list "work" [file normalize "${hardware}/lib/fluart/fluart.vhdl"]]
lappend hdl_files [list "work" [file normalize "${hardware}/lib/cmd_proc/cmd_proc.vhdl"]]
