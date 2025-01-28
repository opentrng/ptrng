import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge
import signaltools as Signal

async def write(dut, word):
	await RisingEdge(dut.clk)
	dut.data_in.value = word
	dut.wr.value = 1
	await RisingEdge(dut.clk)
	dut.data_in.value = 0
	dut.wr.value = 0

async def read(dut):
	await RisingEdge(dut.clk)
	dut.rd.value = 1
	word = dut.data_out.value
	await RisingEdge(dut.clk)
	dut.rd.value = 0
	return word

async def readwrite(dut, write_word):
	await RisingEdge(dut.clk)
	dut.rd.value = 1
	read_word = dut.data_out.value
	dut.data_in.value = write_word
	dut.wr.value = 1
	await RisingEdge(dut.clk)
	dut.rd.value = 0
	dut.data_in.value = 0
	dut.wr.value = 0
	return read_word

@cocotb.test()
async def flags(dut):
	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	dut.rd.value = 0
	await Signal.PulseBit(dut.clear, dut.clk)
	assert dut.empty.value == 1
	await write(dut, 1)
	await FallingEdge(dut.clk)
	assert dut.empty.value == 0
	assert dut.almost_empty.value == 1
	await write(dut, 2)
	await write(dut, 3)
	await FallingEdge(dut.clk)
	assert dut.empty.value == 0
	assert dut.almost_empty.value == 0
	await write(dut, 4)
	await write(dut, 5)
	await write(dut, 6)
	await FallingEdge(dut.clk)
	assert dut.full.value == 0
	assert dut.almost_full.value == 1
	await write(dut, 7)
	await write(dut, 8)
	await FallingEdge(dut.clk)
	assert dut.full.value == 1
	assert dut.almost_full.value == 1
	await write(dut, 9)
	assert dut.data_out.value == 1


	await Signal.Skip(dut.clk, 100)

@cocotb.test()
async def discrete_read_write(dut):
	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	dut.rd.value = 0
	await Signal.PulseBit(dut.clear, dut.clk)
	await write(dut, 1)
	await write(dut, 2)
	await write(dut, 3)
	await write(dut, 4)
	assert await read(dut) == 1
	await write(dut, 5)
	assert await read(dut) == 2
	assert await read(dut) == 3
	assert await read(dut) == 4
	assert await read(dut) == 5
	await Signal.Skip(dut.clk, 100)

@cocotb.test()
async def continuous_read_write(dut):
	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	dut.rd.value = 0
	await Signal.PulseBit(dut.clear, dut.clk)
	await write(dut, 1)
	await write(dut, 2)
	await write(dut, 3)
	await write(dut, 4)
	assert await readwrite(dut, 5) == 1
	assert await readwrite(dut, 6) == 2
	assert await readwrite(dut, 7) == 3
	assert await readwrite(dut, 8) == 4
	assert await readwrite(dut, 9) == 5
	assert await readwrite(dut, 10) == 6
	assert await readwrite(dut, 12) == 7
	assert await readwrite(dut, 13) == 8
	assert await readwrite(dut, 14) == 9
	assert await readwrite(dut, 15) == 10
	await Signal.Skip(dut.clk, 100)
