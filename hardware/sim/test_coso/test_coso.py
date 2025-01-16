import cocotb
from cocotb.clock import Clock
from cocotb.clock import Timer
from cocotb.triggers import ClockCycles, RisingEdge
import signaltools as Signal

@cocotb.test()
async def test_total_failure_alarm(dut):
	await cocotb.start(Clock(dut.ro0, 10, units="ns").start())
	await cocotb.start(Clock(dut.ro1, 10, units="ns").start())
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	await ClockCycles(dut.ro0, 2, rising=True)
	for i in range(1000):
		await RisingEdge(dut.ro0)
		assert dut.clk.value == 1, "When RO0 and RO1 are locked, beat signal should be stucked at logic 1"

@cocotb.test()
async def test_gen_random_100(dut):
	await cocotb.start(Signal.NoisyClock(dut.ro0, 500e6))
	await cocotb.start(Signal.NoisyClock(dut.ro1, 501e6))
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	for i in range(100):
		await RisingEdge(dut.clk)
		dut._log.info("Random bit {:d} (COSO counter {:d})".format(dut.lsb.value.integer, dut.data.value.integer))
