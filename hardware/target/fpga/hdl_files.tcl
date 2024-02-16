# Add design HDL source files to the list
set hdl_files [list \
	[file normalize "../../hdl/clkdivider.vhd"] \
	[file normalize "../../hdl/coso.vhd"] \
	[file normalize "../../hdl/digitalnoise.vhd"] \
	[file normalize "../../hdl/ero.vhd"] \
	[file normalize "../../hdl/freqcounter.vhd"] \
	[file normalize "../../hdl/ptrng.vhd"] \
	[file normalize "../../hdl/top.vhd"] \
]

# Add configuration files
lappend hdl_files [file normalize "../../config/registers/regmap.vhd"]
lappend hdl_files [file normalize "../../config/digitalnoise/settings.vhd"]

# Add required HDL sources files from libraries
lappend hdl_files [file normalize "../../lib/fluart/fluart.vhdl"]
lappend hdl_files [file normalize "../../lib/cmd_proc/cmd_proc.vhdl"]
