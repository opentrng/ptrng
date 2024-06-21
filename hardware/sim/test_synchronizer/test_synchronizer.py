import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge
import signaltools as Signal
import random

@cocotb.test()
async def test_resynchronize(dut):
	await cocotb.start(Clock(dut.clk_from, 41, units="ns").start())
	await cocotb.start(Clock(dut.clk_to, 10, units="ns").start())
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	dut.data_in.value = 0
	dut.data_in_en.value = 0
	for i in range(10):
		data = random.randint(0, 0xFFFFFFFF)
		await RisingEdge(dut.clk_from)
		dut.data_in.value = data
		dut.data_in_en.value = 1
		while True:
			await RisingEdge(dut.clk_to)
			if dut.data_out_en.value == 1:
				assert dut.data_out.value == data, "The value read on data_out port is different from expected value!"
				break

