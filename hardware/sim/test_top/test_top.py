import cocotb
from cocotb.clock import Clock, Timer
from cocotb.triggers import RisingEdge, FallingEdge
import signaltools as Signal

async def sim_uart_rx_byte(dut, byte):
	await RisingEdge(dut.clk)
	dut.rx_data.value = byte
	dut.rx_data_valid.value = 1
	await RisingEdge(dut.clk)
	dut.rx_data.value = 0
	dut.rx_data_valid.value = 0
	Signal.Skip(dut.clk, 9)

async def sim_uart_tx_busy(dut):
	dut.tx_busy.value = 0
	while True:
		await FallingEdge(dut.tx_req)
		dut.tx_busy.value = 1
		await Signal.Skip(dut.clk, 10)
		dut.tx_busy.value = 0

@cocotb.test()
async def test_readfifo(dut):

	# Clock settings
	sys_clk_period = 10
	
	# Force some register map settings
	dut.nopacking.value = 1
	dut.freqdivider_value.value = 50
	
	# Force some UART related signals
	dut.rx_data_valid.value = 0
	
	# Create the clocks
	await cocotb.start(Clock(dut.clk, sys_clk_period, units="ns").start())
	await cocotb.start(Signal.NoisyClock(dut.ptrng.source.osc, 94e6))
	
	# Do the resets
	await Signal.SetBitDuring(dut.hw_reset, 50, units="ns")
	await FallingEdge(dut.hw_reset)
	await RisingEdge(dut.clk)
	await Signal.PulseBit(dut.freqdivider_en, dut.clk)
	await Signal.PulseBit(dut.ptrng_reset, dut.clk)

	await Signal.Skip(dut.clk, 300)
	
	# Simulate the tx_busy signal (to shorten emission and have faster simulations)
	await cocotb.start(sim_uart_tx_busy(dut))
	
	await Signal.Skip(dut.clk, 3000)
	
	# Simulate a read burst
	await sim_uart_rx_byte(dut, 0x02)
	await sim_uart_rx_byte(dut, 0x00)
	await sim_uart_rx_byte(dut, 0x24)
	await sim_uart_rx_byte(dut, 0x00)
	await sim_uart_rx_byte(dut, 0x04)
	
	await Signal.Skip(dut.clk, 300)
	
	await sim_uart_rx_byte(dut, 0x02)
	await sim_uart_rx_byte(dut, 0x00)
	await sim_uart_rx_byte(dut, 0x24)
	await sim_uart_rx_byte(dut, 0x00)
	await sim_uart_rx_byte(dut, 0x04)
	
	await Signal.Skip(dut.clk, 1000)
	await Signal.PulseBit(dut.fifo_clear, dut.clk)
	await Signal.Skip(dut.clk, 2000)
	
	await sim_uart_rx_byte(dut, 0x02)
	await sim_uart_rx_byte(dut, 0x00)
	await sim_uart_rx_byte(dut, 0x24)
	await sim_uart_rx_byte(dut, 0x00)
	await sim_uart_rx_byte(dut, 0x08)
	
	
	await Signal.Skip(dut.clk, 1000)

