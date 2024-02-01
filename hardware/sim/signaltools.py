import cocotb
from cocotb.clock import Timer
from cocotb.triggers import ClockCycles, RisingEdge
import emulator

async def Skip(signal, cycles):
	await ClockCycles(signal, cycles, rising=True)

async def PulseBit(signal, clock):
	signal.value = 1
	await RisingEdge(clock)
	signal.value = 0

async def SetBitDuring(signal, duration, units):
	signal.value = 1
	await Timer(duration, units=units)
	signal.value = 0

async def SetBitAfter(signal, duration, units):
	await Timer(duration, units=units)
	signal.value = 1

async def NoisyClock(signal, frequency):
	while True:
		periods = (emulator.generate_periods(1e6, frequency, emulator.A1_F500M, emulator.A2_F500M) * 1e15).astype(int)
		for period in periods:
			half = int(period / 2)
			signal.value = 1
			await Timer(half, units="fs")
			signal.value = 0
			await Timer(period-half, units="fs")
