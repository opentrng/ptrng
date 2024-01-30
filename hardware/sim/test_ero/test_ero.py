import cocotb
from cocotb.clock import Clock
from cocotb.clock import Timer
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge
from cocotb.types import Logic
import emulator

async def noisy_clock(signal, frequency):
	while True:
		periods = (emulator.generate_periods(1e6, frequency, emulator.A1_F500M, emulator.A2_F500M) * 1e15).astype(int)
		for period in periods:
			half = int(period / 2)
			signal.value = 1
			await Timer(half, units="fs")
			signal.value = 0
			await Timer(period-half, units="fs")

@cocotb.test()
async def test_gen_random_100(dut):
	dut.div.value = 1000
	await cocotb.start(noisy_clock(dut.ro0, 500e6))
	await cocotb.start(noisy_clock(dut.ro1, 501e6))
	for i in range(100):
		await RisingEdge(dut.clk)
		print("Random bit {:d}".format(dut.data.value.integer))
