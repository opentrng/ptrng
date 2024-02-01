import cocotb
from cocotb.clock import Clock
from cocotb.clock import Timer
from cocotb.triggers import RisingEdge
from cocotb.handle import Deposit
import signaltools as Signal

@cocotb.test()
async def test_count_frequency(dut):
	dut.reset.value = 0
	dut.enable.value = 0
	dut.start.value = 0
	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	await cocotb.start(Clock(dut.osc, 333, units="ns").start())
	await Signal.SetBitDuring(dut.reset, 5, units="ns")
	await Signal.SetBitAfter(dut.enable, 20, units="ns")
	await Signal.PulseBit(dut.start, dut.clk)
	await RisingEdge(dut.done)
	assert dut.result.value == 30, "Wrong measured frequency, result should be 30"
	await Signal.Skip(dut.clk, 10)

@cocotb.test()
async def test_counter_overflow(dut):
	dut.reset.value = 0
	dut.enable.value = 1
	dut.start.value = 0
	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	await cocotb.start(Clock(dut.osc, 333, units="ns").start())
	await Signal.PulseBit(dut.start, dut.clk)
	await Signal.Skip(dut.clk, 100)
	dut.counter.value = Deposit((2**24)-1)
	await RisingEdge(dut.done)
	assert dut.overflow.value == 1, "The counter overflow has not been detected"
	dut.counter.value = Deposit(0)
	await Signal.Skip(dut.clk, 10)

@cocotb.test()
async def test_duration_overflow(dut):
	dut.reset.value = 0
	dut.enable.value = 1
	dut.start.value = 0
	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	await cocotb.start(Clock(dut.osc, 333, units="ns").start())
	await Signal.PulseBit(dut.start, dut.clk)
	await Signal.Skip(dut.clk, 100)
	dut.duration.value = Deposit(1001)
	await RisingEdge(dut.done)
	assert dut.overflow.value == 1, "The duration overflow has not been detected"
	dut.duration.value = Deposit(0)
	await Signal.Skip(dut.clk, 10)
