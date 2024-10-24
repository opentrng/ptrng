import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import signaltools as Signal

DEPTH = 128

@cocotb.test()
async def valid_test(dut):
	dut.clear.value = 0
	dut.raw_random_number.value = 128
	dut.raw_random_valid.value = 1
	dut.average.value = 128 * DEPTH
	dut.deviation.value = 10
	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	await Signal.Skip(dut.clk, 2) # Skip the reset
	await Signal.Skip(dut.clk, DEPTH+1)
	assert dut.valid.value == 1, "Online test should be valid"
	await Signal.Skip(dut.clk, 10)

@cocotb.test()
async def invalid_test(dut):
	dut.clear.value = 0
	dut.raw_random_number.value = 128
	dut.raw_random_valid.value = 1
	dut.average.value = 100
	dut.deviation.value = 10
	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	await Signal.Skip(dut.clk, 2) # Skip the reset
	await Signal.Skip(dut.clk, DEPTH+1)
	assert dut.valid.value == 0, "Online test should NOT be valid"
	await Signal.Skip(dut.clk, 10)
