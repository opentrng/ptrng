# Add design HDL source files to the list
set hdl_files [list \
	[list "work" [file normalize "../../hdl/clkdivider.vhd"]] \
	[list "work" [file normalize "../../hdl/coso.vhd"]] \
	[list "work" [file normalize "../../hdl/digitizer.vhd"]] \
	[list "work" [file normalize "../../hdl/clockdomain.vhd"]] \
	[list "work" [file normalize "../../hdl/digitalnoise.vhd"]] \
	[list "work" [file normalize "../../hdl/ero.vhd"]] \
	[list "work" [file normalize "../../hdl/freqcounter.vhd"]] \
	[list "work" [file normalize "../../hdl/ptrng.vhd"]] \
	[list "work" [file normalize "../../hdl/top.vhd"]] \
]

# Add configuration files
lappend hdl_files [list "work" [file normalize "../../config/registers/regmap.vhd"]]
lappend hdl_files [list "work" [file normalize "../../config/digitalnoise/settings.vhd"]]

# Add required HDL sources files from libraries
lappend hdl_files [list "work" [file normalize "../../lib/fluart/fluart.vhdl"]]
lappend hdl_files [list "work" [file normalize "../../lib/cmd_proc/cmd_proc.vhdl"]]
lappend hdl_files [list "extras" [file normalize "../../lib/vhdl-extras/rtl/extras/synchronizing.vhdl"]]
lappend hdl_files [list "extras" [file normalize "../../lib/vhdl-extras/rtl/extras_2008/sizing_2008.vhdl"]]
lappend hdl_files [list "extras" [file normalize "../../lib/vhdl-extras/rtl/extras/memory.vhdl"]]
lappend hdl_files [list "extras" [file normalize "../../lib/vhdl-extras/rtl/extras/fifos.vhdl"]]
