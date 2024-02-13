set_false_path -from [get_ports uart_txd_in] -to [get_clocks sys_clk]
set_false_path -from [get_clocks sys_clk] -to [get_ports uart_rxd_out]
