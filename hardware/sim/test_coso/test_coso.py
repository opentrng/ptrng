import cocotb
from cocotb.clock import Clock
from cocotb.clock import Timer
from cocotb.triggers import ClockCycles, RisingEdge
import emulator

@cocotb.test()
async def test_total_failure_alarm(dut):
	await cocotb.start(Clock(dut.ro0, 10, units="ns").start())
	await cocotb.start(Clock(dut.ro1, 10, units="ns").start())
	await ClockCycles(dut.ro0, 2, rising=True)
	for i in range(1000):
		await RisingEdge(dut.ro0)
		assert dut.clk.value == 1, "When RO0 and RO1 are locked, beat signal should be stucked at logic 1"

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
	await cocotb.start(noisy_clock(dut.ro0, 500e6))
	await cocotb.start(noisy_clock(dut.ro1, 501e6))
	for i in range(100):
		await RisingEdge(dut.clk)
		dut._log.info("Random bit {:d} (COSO counter {:d})".format(dut.lsb.value.integer, dut.raw.value.integer))
