set DESIGN_NAME $env(DESIGN_NAME);
#################################################################################
# Read setup files
#     user_functions.tcl defines the DB libraries
#################################################################################
set PRODUCT $env(PRODUCT);
#source $PRODUCT/formal_proof/tools/user_functions.tcl
#read_configuration_file $env(DESIGN_CONFIGURATION)
#read_configuration_file $PRODUCT/config/common/$DESIGN_CONFIGURATION

# The following variables are used by scripts in the rm_dc_scripts folder to direct 
# the location of the output files.
set fulldate [clock format [clock seconds] -format {%g-%m-%d_%H-%M-%S}]

#################################################################################
# Suppress useless WARNING & MESSAGES
#################################################################################
#foreach i $env(MSG_IGNORE_LIST) {
# suppress_message $i
#}

#################################################################################
# Synopsys Auto Setup Mode
#################################################################################
set_app_var synopsys_auto_setup true
set_app_var verification_clock_gate_edge_analysis true
set hdlin_dwroot /common/soft/synopsys/syn/V-2023.12-SP4

# Example of guide multiplier
#guide_multiplier -design ip_icss_fir_mac -arch csa -body ../rtl/modules/ip_icss/ip_icss_fir/ip_icss_fir_mac_rtl.v

#################################################################################
# Change the number of fail before halting the formality process
#################################################################################
set verification_failing_point_limit 3000

#################################################################################
# Read in the SVF file(s)
#################################################################################
# Set this variable to point to individual SVF file(s) or to a directory containing SVF files.
#set svf_file $PRODUCT/syn/results/syn_out/chip_top.mapped.svf

#if { ![set_svf $svf_file] } {
#  puts "-E- incorrect svf"
#  exit
#}

#################################################################################
# Read in the libraries
#################################################################################
#set link_db [safe_get_db_from_design_configuration $env(DESIGN_CONFIGURATION) MAX_125 "ccs"]
#echo $env(DESIGN_CONFIGURATION)
#echo $link_db
#foreach tech_lib $link_db {             
#  read_db -technology_library $tech_lib 
#}        
#  source $PRODUCT/formal_proof/tools/filelist.tcl ;

  #################################################################################
  # Process RTL_INCDIR for removing +incdir+ and resolve $PRODUCT variable
  #################################################################################
#  set rtl_incdir ""
#  foreach i $RTL_INCDIR {
#    set incdir_name [string map -nocase [list +incdir+\$PRODUCT $PRODUCT] $i]
#    set rtl_incdir [string cat $rtl_incdir " +incdir+" $incdir_name]
#  }

  #################################################################################
  # Process VLOG_SOURCE_FILES for resolving $PRODUCT variable
  # Deals with both sv and v files in the same list to analyze them in one pass (to have defines taken into account in sv files)
  #################################################################################
  

#foreach i $VHDL_SOURCE_FILES {
#      set vhdl_name [string map -nocase [list \$PRODUCT $PRODUCT] [lindex $i 0]]
#      set library_name [lindex $i 1]
#      define_design_lib $library_name -path ./WORK_VHDL/$library_name
#      read_vhdl -r $vhdl_name -work_library $library_name
#}


if {$DESIGN_NAME == "ptrng"} {
  set hdlin_unresolved_modules black_box
  set hdlin_interface_only ring
}

define_design_lib -r work -path ./WORK_VHDL/work

read_vhdl -r $PRODUCT/hardware/config/digitalnoise/constants.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/config/digitalnoise/settings.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/target/common/xilinx/vhdl/dpfifo_stub.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/target/common/generic/vhdl/fifo.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/target/common/generic/vhdl/ring.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/hdl/vhdl/ptrng/clkdivider.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/hdl/vhdl/ptrng/ero.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/hdl/vhdl/ptrng/muro.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/hdl/vhdl/ptrng/coso.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/hdl/vhdl/ptrng/digitizer.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/hdl/vhdl/ptrng/freqcounter.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/hdl/vhdl/ptrng/synchronizer.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/hdl/vhdl/ptrng/digitalnoise.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/hdl/vhdl/ptrng/alarm.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/hdl/vhdl/ptrng/onlinetest.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/hdl/vhdl/ptrng/conditioner.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/hdl/vhdl/ptrng/bitpacker.vhd -work_library work
read_vhdl -r $PRODUCT/hardware/hdl/vhdl/ptrng/ptrng.vhd -work_library work

#read_vhdl -r $PRODUCT/hardware/target/common/xilinx/vhdl/adc_stub.vhd -work_library work
#read_vhdl -r $PRODUCT/hardware/hdl/vhdl/analog.vhd -work_library work
#read_vhdl -r $PRODUCT/hardware/lib/fluart/fluart.vhdl
#read_vhdl -r $PRODUCT/hardware/lib/cmd_proc/cmd_proc.vhdl
#read_vhdl -r $PRODUCT/hardware/config/registers/regmap.vhd
#read_vhdl -r $PRODUCT/hardware/hdl/vhdl/top.vhd -work_library work


#set hdlin_interface_only "ring"
#set hdlin_interface_only "ring"

# set_black_box r:/OPENTRNG/ring
# set_black_box i:/WORK/ring

if {$DESIGN_NAME == "ptrng"} {
  set_top r:/work/${DESIGN_NAME} -parameter REG_WIDTH=32,RAND_WIDTH=32
} else {
  set_top r:/work/${DESIGN_NAME} -parameter N=20
  #set_top r:/work/${DESIGN_NAME} -parameter CLK_REF=100000000,FIFO_SIZE=32,BURST_SIZE=32
}
#set_top r:/opentrng/onlinetest -parameter REG_WIDTH=32,RAND_WIDTH=32,DEPTH=128
#set_top r:/opentrng/fifo -parameter SIZE=512,ALMOST_EMPTY_SIZE=0,ALMOST_FULL_SIZE=512,DATA_WIDTH=32
#set_top r:/opentrng/fifo -parameter SIZE=32,ALMOST_EMPTY_SIZE=0,ALMOST_FULL_SIZE=32,DATA_WIDTH=32
#set_top r:/opentrng/ring -parameter N=2


#set vlog_source_files ""
#  foreach i $VLOG_SOURCE_FILES {
#    set vlog_name [string map -nocase [list \$PRODUCT $PRODUCT] $i]
#    lappend vlog_source_files $vlog_name 
#}

#read_sverilog -i $vlog_source_files -work_library WORK -define $env(VERILOG_DEFINE_STRING) -vcs $rtl_incdir


define_design_lib -i work -path ./WORK_VHDL/work

read_sverilog -i $PRODUCT/hardware/config/digitalnoise/constants.v
read_sverilog -i $PRODUCT/hardware/config/digitalnoise/settings.v
read_sverilog -i $PRODUCT/hardware/target/common/xilinx/verilog/dpfifo_stub.v
read_sverilog -i $PRODUCT/hardware/target/common/generic/verilog/fifo.v
read_sverilog -i $PRODUCT/hardware/hdl/verilog/ptrng/bitpacker.v
read_sverilog -i $PRODUCT/hardware/hdl/verilog/ptrng/clkdivider.v
read_sverilog -i $PRODUCT/hardware/hdl/verilog/ptrng/conditioner.v
read_sverilog -i $PRODUCT/hardware/hdl/verilog/ptrng/coso.v
read_sverilog -i $PRODUCT/hardware/hdl/verilog/ptrng/digitalnoise.v
read_sverilog -i $PRODUCT/hardware/hdl/verilog/ptrng/digitizer.v
read_sverilog -i $PRODUCT/hardware/hdl/verilog/ptrng/ero.v
read_sverilog -i $PRODUCT/hardware/hdl/verilog/ptrng/freqcounter.v
read_sverilog -i $PRODUCT/hardware/hdl/verilog/ptrng/muro.v
read_sverilog -i $PRODUCT/hardware/hdl/verilog/ptrng/onlinetest.v
read_sverilog -i $PRODUCT/hardware/hdl/verilog/ptrng/synchronizer.v
read_sverilog -i $PRODUCT/hardware/hdl/verilog/ptrng/ptrng.v
read_sverilog -i $PRODUCT/hardware/target/common/generic/verilog/ring.v
read_sverilog -i $PRODUCT/hardware/hdl/verilog/ptrng/alarm.v


#read_sverilog -i $PRODUCT/hardware/target/common/xilinx/verilog/adc_stub.v
#read_sverilog -i $PRODUCT/hardware/hdl/verilog/analog.v
#read_vhdl -i $PRODUCT/hardware/lib/fluart/fluart.vhdl
#read_vhdl -i $PRODUCT/hardware/lib/cmd_proc/cmd_proc.vhdl
#read_vhdl -i $PRODUCT/hardware/config/registers/regmap.vhd
#read_sverilog -i $PRODUCT/hardware/hdl/verilog/top.v


if {$DESIGN_NAME == "ptrng"} {
  set_top i:/WORK/${DESIGN_NAME} -parameter REG_WIDTH=32,RAND_WIDTH=32
} else {
  set_top i:/WORK/${DESIGN_NAME} -parameter N=20
  #set_top i:/WORK/${DESIGN_NAME}  -parameter CLK_REF=100000000,FIFO_SIZE=32,BURST_SIZE=32
}
#set_top i:/WORK/onlinetest -parameter REG_WIDTH=32,RAND_WIDTH=32,DEPTH=128
#set_top i:/WORK/fifo -parameter SIZE=512,ALMOST_EMPTY_SIZE=0,ALMOST_FULL_SIZE=512,DATA_WIDTH=32
#set_top i:/WORK/fifo -parameter SIZE=32,ALMOST_EMPTY_SIZE=0,ALMOST_FULL_SIZE=32,DATA_WIDTH=32
#set_top i:/WORK/ring -parameter N=1

#set_parameter -resolution blackbox r:/OPENTRNG/dpfifo 
#set_parameter -resolution blackbox i:/WORK/dpfifo 


#set_app_var upf_use_additional_db_attributes true ; # already set to true because "synopsys_auto_setup" variable is set to true previously
#
#
#
#
#
#
#set safe_gater {}
#
#foreach i $safe_gater {
#  set matching_impl [ get_cells [ string map ". _" i:/WORK/ptrng/$i* ] ]
#  if {[sizeof_collection $matching_impl] == 0} {
#    puts "-E- No found $i"
#  } else {
#    foreach_in_collection k $matching_impl {
#      set_user_match r:/WORK_VHDL/ptrng/$i $k
#    }
#  }
#}

#################################################################################
# Match compare points and report unmatched points 
#################################################################################
match
if {$DESIGN_NAME == "ptrng"} {
  report_unmatched_points > $PRODUCT/hardware/hdl/proof/reports/opentrng_${fulldate}.fmv_unmatched_points.rpt
} else {
  report_unmatched_points > $PRODUCT/hardware/hdl/proof/reports/opentrng_ring_${fulldate}.fmv_unmatched_points.rpt
}

#set_black_box r:/OPENTRNG/dpfifo 
#set_black_box i:/WORK/dpfifo 

#if {[info exits env(SAVE_SESSION)]} {
#  save_session -replace $PRODUCT/formal_proof/work/save_session_aftermatch.fss
#}

#################################################################################
# Verify and Report
#
# If the verification is not successful, the session will be saved and reports
# will be generated to help debug the failed or inconclusive verification.
#################################################################################
set verification_partition_timeout_limit 5:0:0
set verification_timeout_limit 10:0:0
# start_gui may be usefull to debug verify step
#start_gui
verify

#if {[info exits env(SAVE_SESSION)]} {
#  save_session -replace $PRODUCT/formal_proof/work/save_session_afterverify.fss 
#}

if {$DESIGN_NAME == "ptrng"} {
  report_failing_points > $PRODUCT/hardware/hdl/proof/reports/opentrng_${fulldate}.fmv_failing_points.rpt
  report_aborted_points > $PRODUCT/hardware/hdl/proof/reports/opentrng_${fulldate}.fmv_aborted_points.rpt
  report_unread_endpoints -all > $PRODUCT/hardware/hdl/proof/reports/opentrng_${fulldate}.fmv_unread_endpoints.rpt
} else {
  report_failing_points > $PRODUCT/hardware/hdl/proof/reports/opentrng_ring_${fulldate}.fmv_failing_points.rpt
  report_aborted_points > $PRODUCT/hardware/hdl/proof/reports/opentrng_ring_${fulldate}.fmv_aborted_points.rpt
  report_unread_endpoints -all > $PRODUCT/hardware/hdl/proof/reports/opentrng_ring_${fulldate}.fmv_unread_endpoints.rpt
}

# Use analyze_points to help determine the next step in resolving verification
# issues. It runs heuristic analysis to determine if there are potential causes
# other than logical differences for failing or hard verification points. 
#analyze_points -all > $PRODUCT/fm/reports/${FMRM_ANALYZE_POINTS_REPORT}

exit

