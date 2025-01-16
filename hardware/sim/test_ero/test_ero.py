import cocotb
from cocotb.clock import Timer
from cocotb.triggers import RisingEdge
import signaltools as Signal

@cocotb.test()
async def test_gen_random_100(dut):
	dut.divider.value = 1000
	await cocotb.start(Signal.NoisyClock(dut.ro0, 500e6))
	await cocotb.start(Signal.NoisyClock(dut.ro1, 501e6))
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	await Signal.PulseBit(dut.changed, dut.ro0)
	for i in range(100):
		await RisingEdge(dut.clk)
		dut._log.info("Random bit {:d}".format(dut.data.value.integer))
