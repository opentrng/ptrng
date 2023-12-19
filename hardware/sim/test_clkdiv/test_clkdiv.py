import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge

async def do_division_by_n(dut, n):
	original_period = 10
	wait = 5
	cycles = 1000
	await cocotb.start(Clock(dut.original, original_period, units="ns").start())
	dut.factor.value = n
	await ClockCycles(dut.divided, wait, rising=True)
	start_time = cocotb.utils.get_sim_time(units='ns')
	await ClockCycles(dut.divided, cycles, rising=True)
	measured_time = round(cocotb.utils.get_sim_time(units='ns')-start_time)
	estimated_time = original_period*n*cycles
	assert measured_time == estimated_time, "Wrong duration for %d divided clock cycles" % cycles

@cocotb.test()
async def test_division_by_zero(dut):
	cycles = 1000
	dut.factor.value = 0
	await cocotb.start(Clock(dut.original, 10, units="ns").start())
	for i in range(cycles):
		await RisingEdge(dut.original)
		assert dut.divided.value == 0, "Divided clock output is not tied to logic 0"

@cocotb.test()
async def test_division_by_1(dut):
	await do_division_by_n(dut, 1)

@cocotb.test()
async def test_division_by_2(dut):
	await do_division_by_n(dut, 2)

@cocotb.test()
async def test_division_by_3(dut):
	await do_division_by_n(dut, 3)

@cocotb.test()
async def test_division_by_5(dut):
	await do_division_by_n(dut, 5)

@cocotb.test()
async def test_division_by_10(dut):
	await do_division_by_n(dut, 10)

@cocotb.test()
async def test_division_by_100(dut):
	await do_division_by_n(dut, 100)

@cocotb.test()
async def test_duty_cycle(dut):
	cycles = 1000
	count = [0, 0]
	dut.factor.value = 5
	await cocotb.start(Clock(dut.original, 10, units="ns").start())
	for i in range(cycles):
		await FallingEdge(dut.original)
		count[dut.divided.value] += 1
	duty_cycle = int(100*count[0]/cycles)
	assert duty_cycle >= 40 and duty_cycle <= 60, "Duty cycle not in range [40, 50]"
