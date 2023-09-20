add wave -divider {Noisy ring oscillators}
add wave sim:/dut/ro1
add wave sim:/dut/ro2
add wave -divider {COSO internal}
add wave sim:/dut/beat
add wave -radix unsigned sim:/dut/counter
add wave -divider {COSO output}
add wave sim:/dut/clk
add wave sim:/dut/lsb
add wave -radix unsigned sim:/dut/raw
