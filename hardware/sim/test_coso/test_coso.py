import cocotb
from cocotb.clock import Clock
from cocotb.clock import Timer
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge
from cocotb.types import Logic

import numpy as np
import itertools

import sys
sys.path.insert(0, '../../../emulator')
import utils

@cocotb.test()
async def test_total_failure_alarm(dut):
	await cocotb.start(Clock(dut.ro1, 10, units="ns").start())
	await cocotb.start(Clock(dut.ro2, 10, units="ns").start())
	await ClockCycles(dut.ro2, 2, rising=True)
	for i in range(1000):
		await RisingEdge(dut.ro2)
		assert dut.clk.value == 1, "When RO1 and RO2 are locked, beat signal should be stucked at logic 1"

async def noisy_clock(signal, frequency):
	while True:
		periods = utils.generate_series(1e6, frequency)
		for period in periods:
			half = int(period / 2)
			signal.value = 1
			await Timer(half, units="fs")
			signal.value = 0
			await Timer(period-half, units="fs")

@cocotb.test()
async def test_gen_random_100(dut):
	await cocotb.start(noisy_clock(dut.ro1, 500e6))
	await cocotb.start(noisy_clock(dut.ro2, 501e6))
	for i in range(100):
		await RisingEdge(dut.clk)
		print("Random bit {:d} (COSO counter {:d})".format(dut.lsb.value.integer, dut.raw.value.integer))
