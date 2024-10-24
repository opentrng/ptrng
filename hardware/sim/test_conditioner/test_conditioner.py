import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge
import signaltools as Signal

async def append_bit(clock, bit, valid, array):
	await RisingEdge(clock)
	if valid.value == 1:
		array.append(bit.value.integer)
	return array

@cocotb.test()
async def basic_tests(dut):
	dut.enable.value = 1
	dut.raw_random_number.value = 0
	dut.raw_random_valid.value = 0
	irn_reference = [3, 4, 3, 4]
	irn_simulation = []

	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	await Signal.Skip(dut.clk, 2) # Skip the reset

	dut.raw_random_number.value = 3
	await Signal.PulseBit(dut.raw_random_valid, dut.clk)
	irn_simulation = await append_bit(dut.clk, dut.conditioned_number, dut.conditioned_valid, irn_simulation)
	dut.raw_random_number.value = 4
	await Signal.PulseBit(dut.raw_random_valid, dut.clk)
	irn_simulation = await append_bit(dut.clk, dut.conditioned_number, dut.conditioned_valid, irn_simulation)
	dut.raw_random_number.value = 3
	await Signal.PulseBit(dut.raw_random_valid, dut.clk)
	irn_simulation = await append_bit(dut.clk, dut.conditioned_number, dut.conditioned_valid, irn_simulation)
	dut.raw_random_number.value = 3
	await Signal.PulseBit(dut.raw_random_valid, dut.clk)
	irn_simulation = await append_bit(dut.clk, dut.conditioned_number, dut.conditioned_valid, irn_simulation)
	dut.raw_random_number.value = 3
	await Signal.PulseBit(dut.raw_random_valid, dut.clk)
	irn_simulation = await append_bit(dut.clk, dut.conditioned_number, dut.conditioned_valid, irn_simulation)
	dut.raw_random_number.value = 4
	await Signal.PulseBit(dut.raw_random_valid, dut.clk)
	irn_simulation = await append_bit(dut.clk, dut.conditioned_number, dut.conditioned_valid, irn_simulation)

	await Signal.Skip(dut.clk, 10)
	assert irn_simulation == irn_reference
