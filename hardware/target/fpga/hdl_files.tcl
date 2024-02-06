# Add design HDL source files to the list
set hdl_files [list \
	[file normalize "../../hdl/clkdiv.vhd"] \
	[file normalize "../../hdl/coso.vhd"] \
	[file normalize "../../hdl/ero.vhd"] \
	[file normalize "../../hdl/freqcounter.vhd"] \
	[file normalize "../../hdl/ptrng.vhd"] \
	[file normalize "../../hdl/registers.vhd"] \
	[file normalize "../../hdl/settings.vhd"] \
	[file normalize "../../hdl/top.vhd"] \
]

# Add required HDL sources files from libraries
lappend hdl_files [file normalize "../../lib/fluart/fluart.vhdl"]
lappend hdl_files [file normalize "../../lib/cmd_proc/cmd_proc.vhdl"]
