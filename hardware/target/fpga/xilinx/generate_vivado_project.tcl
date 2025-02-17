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

# Set paths
set hardware "../../.."
set custom "${hardware}/lib/custom"

# Set VHDL source files into a list
source "${hardware}/target/fpga/hdl_files.tcl"
lappend hdl_files [list "work" [file normalize "${boardname}/target.vhd"]]
lappend hdl_files [list "work" [file normalize "${hardware}/target/common/xilinx/adc.vhd"]]
lappend hdl_files [list "opentrng" [file normalize "${hardware}/target/common/xilinx/ring.vhd"]]

# If custom HDL files exist add them to the list
if { [file exists "${custom}/hdl_files.tcl"] == 1} {
	source "${custom}/hdl_files.tcl"
} 

# Set constraints files into a list (first file will be defined as target constraint file)
set constraints_files [list \
	[file normalize "${boardname}/target.xdc"] \
	[file normalize "${hardware}/target/common/xilinx/top.xdc"] \
	[file normalize "${hardware}/config/digitalnoise/constraints.xdc"] \
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
	read_vhdl -library [lindex $hdl_file 0] -vhdl2008 [lindex $hdl_file 1]
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

# Load the project with this command: vivado -mode gui ${boardname}/opentrng_${boardname}.xpr"
quit
