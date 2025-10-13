# Add design HDL source files to the list
set hdl_files_verilog [list \
	[list "opentrng" [file normalize "${hardware}/hdl/verilog/ptrng/clkdivider.v"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/verilog/ptrng/bitpacker.v"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/verilog/ptrng/ero.v"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/verilog/ptrng/muro.v"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/verilog/ptrng/coso.v"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/verilog/ptrng/digitizer.v"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/verilog/ptrng/synchronizer.v"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/verilog/ptrng/digitalnoise.v"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/verilog/ptrng/freqcounter.v"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/verilog/ptrng/alarm.v"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/verilog/ptrng/onlinetest.v"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/verilog/ptrng/conditioner.v"]] \
	[list "opentrng" [file normalize "${hardware}/hdl/verilog/ptrng/ptrng.v"]] \
]

# Add configuration files
lappend hdl_files_vhdl [list "work" [file normalize "${hardware}/config/digitalnoise/constants.vhd"]]
lappend hdl_files_vhdl [list "work" [file normalize "${hardware}/config/digitalnoise/settings.vhd"]]
lappend hdl_files_verilog [list "opentrng" [file normalize "${hardware}/config/digitalnoise/constants.v"]]
lappend hdl_files_verilog [list "opentrng" [file normalize "${hardware}/config/digitalnoise/settings.v"]]

# Add required utility sources files
lappend hdl_files_verilog [list "opentrng" [file normalize "${hardware}/target/common/generic/verilog/fifo.v"]]
lappend hdl_files_vhdl [list "work" [file normalize "${hardware}/config/registers/regmap.vhd"]]
lappend hdl_files_verilog [list "opentrng" [file normalize "${hardware}/hdl/verilog/analog.v"]]

# Add opentrng top file
lappend hdl_files_verilog [list "opentrng" [file normalize "${hardware}/hdl/verilog/top.v"]]

# Add required HDL sources files from libraries
lappend hdl_files_vhdl [list "work" [file normalize "${hardware}/lib/fluart/fluart.vhdl"]]
lappend hdl_files_vhdl [list "work" [file normalize "${hardware}/lib/cmd_proc/cmd_proc.vhdl"]]
