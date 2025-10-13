open_hw
connect_hw_server
open_hw_target
set_property PROGRAM.FILE [lindex $argv 0] [current_hw_device]
program_hw_devices [current_hw_device]
