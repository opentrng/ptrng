set_false_path -from [get_ports uart_txd_in] -to [get_clocks sys_clk_pin]
set_false_path -from [get_clocks sys_clk_pin] -to [get_ports uart_rxd_out]
