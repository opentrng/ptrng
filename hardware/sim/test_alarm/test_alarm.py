import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import signaltools as Signal

@cocotb.test()
async def default_failure(dut):
	dut.digitizer.value = -1
	dut.threshold.value = 0
	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	await Signal.Skip(dut.clk, 2) # Skip the reset
	assert dut.detected.value == 1, "The default failure must be always 1"

@cocotb.test()
async def ero_or_muro_failure(dut):
	dut.digitizer.value = 1
	dut.threshold.value = 10
	dut.raw_random_number.value = 0
	dut.raw_random_valid.value = 0
	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	for i in range(dut.threshold.value):
		await RisingEdge(dut.clk)
		dut.raw_random_valid.value = 1
		await RisingEdge(dut.clk)
		dut.raw_random_valid.value = 0
		await RisingEdge(dut.clk)
		if i < dut.threshold.value.integer:
			assert dut.detected.value == 0, "No failure should have been detected for now"
		else:
			assert dut.detected.value == 1, "Failure was not detected"
		await Signal.Skip(dut.clk, 10)

@cocotb.test()
async def ero_or_muro_no_failure(dut):
	dut.digitizer.value = 1
	dut.threshold.value = 10
	dut.raw_random_number.value = 0
	dut.raw_random_valid.value = 0
	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	for i in range(dut.threshold.value):
		await RisingEdge(dut.clk)
		dut.raw_random_number.value = i
		dut.raw_random_valid.value = 1
		await RisingEdge(dut.clk)
		dut.raw_random_valid.value = 0
		await RisingEdge(dut.clk)
		assert dut.detected.value == 0, "No failure should have been detected"
		await Signal.Skip(dut.clk, 10)

@cocotb.test()
async def coso_failure(dut):
	dut.digitizer.value = 3
	dut.threshold.value = 10
	dut.raw_random_number.value = 0
	dut.raw_random_valid.value = 1
	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	await Signal.Skip(dut.clk, 2) # Skip the reset
	await Signal.Skip(dut.clk, dut.threshold.value)
	assert dut.detected.value == 1, "Failure was not detected"
	await Signal.Skip(dut.clk, 10)

@cocotb.test()
async def coso_no_failure(dut):
	dut.digitizer.value = 3
	dut.threshold.value = 10
	dut.raw_random_number.value = 0
	dut.raw_random_valid.value = 0
	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	await Signal.Skip(dut.clk, 2) # Skip the reset
	for i in range(dut.threshold.value):
		await RisingEdge(dut.clk)
		dut.raw_random_number.value = i
		dut.raw_random_valid.value = 1
	assert dut.detected.value == 0, "No failure should have been detected"
	await Signal.Skip(dut.clk, 10)
