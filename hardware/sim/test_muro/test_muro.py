import cocotb
from cocotb.clock import Clock
from cocotb.clock import Timer
from cocotb.triggers import RisingEdge
import signaltools as Signal

@cocotb.test()
async def test_gen_random_100(dut):
	dut.div.value = 1000
	await cocotb.start(Signal.NoisyClock(dut.ro0, 500e6))
	await cocotb.start(Signal.NoisyClock(dut.ro1, 488e6))
	await cocotb.start(Signal.NoisyClock(dut.ro2, 497e6))
	await cocotb.start(Signal.NoisyClock(dut.ro3, 501e6))
	await cocotb.start(Signal.NoisyClock(dut.ro4, 503e6))
	await cocotb.start(Signal.NoisyClock(dut.ro5, 509e6))
	await RisingEdge(dut.clk)
	for i in range(100):
		await RisingEdge(dut.clk)
		dut._log.info("Random bit {:d}".format(dut.data.value.integer))
