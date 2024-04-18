import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
import signaltools as Signal

async def write_32bits_word(dut, value):
	first = True
	for i in range(32):
		if first and i == 31:
			first = False
		dut.data_in.value = 0x1 & value>>i
		await Signal.PulseBit(dut.valid_in, dut.clk)
		await RisingEdge(dut.clk)
		if i==0 and not first:
			assert dut.valid_out.value == 1, "A value is expected on data_out port!"
			assert dut.data_out.value == value-1, "The value read on data_out port is different from expected value!"
		await Signal.Skip(dut.clk, 4)

@cocotb.test()
async def pack_10_words(dut):
	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	value = 0xABCD0123
	for i in range(10):
		await write_32bits_word(dut, value)
		value = value+1
