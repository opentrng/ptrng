# ###############################################################################################
# This script is used to create a Xilinx Vivado project.                                        #
# ###############################################################################################
# Simple example to create the project for arty_a7_35t                                          #
# $ cd hardware/target/fpga                                                                     #
# $ vivado -mode tcl -source generate_vivado_project.tcl -tclargs arty_a7_35t xc7a35ticsg324-1L #
# ###############################################################################################

# Check tcl script arguments
if { $::argc != 2 } {
	puts "Usage: $::argv0 <boardname> <partnumber>"
	quit
}

# Fetch tcl args
set boardname [lindex $argv 0]
set partnumber [lindex $argv 1]

# Set VHDL source files into a list
source "hdl_files.tcl"
lappend hdl_files [file normalize "${boardname}/target.vhd"]
lappend hdl_files [file normalize "../common/xilinx/ring.vhd"]

# Set constraints files into a list (first file will be defined as target constraint file)
set constraints_files [list \
	[file normalize "${boardname}/target.xdc"] \
	[file normalize "../common/xilinx/top.xdc"] \
	[file normalize "../../config/digitalnoise/constraints.xdc"] \
]

# Create an empty projet for given partnumber
create_project -force "opentrng_${boardname}" ${boardname}
set proj_dir [get_property directory [current_project]]
set obj [get_projects [current_project]]
set_property "part" $partnumber $obj

# Create a fileset for source files and set language to VHDL
set_property "target_language" "VHDL" $obj
if {[string equal [get_filesets -quiet sources_1] ""]} {
 	create_fileset -srcset sources_1
}

# Link all VHDL files into project
foreach hdl_file $hdl_files {	
	read_vhdl -vhdl2008 $hdl_file
}

# Set the top manually
set obj [get_filesets sources_1]
set_property -name "top" -value "target" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj

# Create a fileset for constraints
if {[string equal [get_filesets -quiet constrs_1] ""]} {
 	create_fileset -constrset constrs_1
}

# Load the constraint files (only for implementation, not for synthesis)
foreach constraints_file $constraints_files {	
	add_files -fileset constrs_1 $constraints_file
}

# Set the target contraint file
set_property target_constrs_file [lindex $constraints_files 0] [current_fileset -constrset]

# End, then load the project with this command: vivado -mode gui arty_a7_35t/opentrng_arty_a7_35t.xpr
quit
