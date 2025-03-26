import cocotb
from cocotb.clock import Clock, Timer
from cocotb.triggers import RisingEdge, FallingEdge
import signaltools as Signal

@cocotb.test()
async def test_coso_onlinetest_valid(dut):

	# Intitial condition
	dut.raw_random_number.value = 0
	dut.raw_random_valid.value = 0

	# Setings
	dut.alarm.digitizer = 3 # COSO
	dut.alarm_threshold.value = 100
	dut.onlinetest_average.value = 200*64
	dut.onlinetest_deviation.value = 10*64
	dut.conditioning.value = 1
	dut.nopacking.value = 1
	
	# Create the clock
	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	
	# Do the resets
	await Signal.PulseBit(dut.reset, dut.clk)
	await Signal.PulseBit(dut.clear, dut.clk)

	values = [200, 198, 201, 204, 198, 202, 198, 205, 203, 197, 205, 205, 205, 197, 198, 197, 201, 204, 200, 196, 204, 205, 204, 196, 199, 202, 198, 203, 197, 200, 203, 205, 202, 204, 198, 201, 200, 197, 203, 202, 198, 199, 199, 196, 198, 204, 205, 195, 204, 197, 203, 198, 203, 196, 199, 195, 195, 201, 201, 200, 201, 197, 198, 203, 198, 205, 200, 198, 202, 203, 200, 200, 202, 205, 195, 201, 202, 199, 202, 200, 202, 203, 197, 203, 203, 204, 199, 202, 205, 205, 200, 196, 197, 204, 205, 196, 201, 195, 199, 196]

	for value in values:
		await FallingEdge(dut.clk)
		dut.raw_random_number.value = value
		dut.raw_random_valid.value = 1
		await FallingEdge(dut.clk)
		dut.raw_random_valid.value = 0
		await Signal.Skip(dut.clk, 10)
		assert dut.onlinetest_valid.value == 1, "Online test should be valid"
	
	await Signal.Skip(dut.clk, 50)

@cocotb.test()
async def test_coso_conditioning(dut):

	await cocotb.start(Clock(dut.clk, 10, units="ns").start())

	for value in [200, 200, 200, 200, 200, 200, 200, 201]:
		assert dut.conditioned_valid.value == 0, "Conditioner should not output any consecutive value"
		await FallingEdge(dut.clk)
		dut.raw_random_number.value = value
		dut.raw_random_valid.value = 1
		await FallingEdge(dut.clk)
		dut.raw_random_valid.value = 0
		await Signal.Skip(dut.clk, 10)
		
	assert dut.conditioned_number.value == 200, "Conditioner should have output last consecutive value"
	
	await Signal.Skip(dut.clk, 50)

@cocotb.test()
async def test_coso_onlinetest_invalid(dut):

	await cocotb.start(Clock(dut.clk, 10, units="ns").start())

	counter = [297, 295, 303, 305, 302, 302, 298, 300, 300, 301, 299, 304, 301, 299, 303, 299, 295, 304, 299, 296, 299, 305, 298, 300, 297, 305, 300, 299, 297, 298, 297, 304, 297, 295, 304, 305, 301, 297, 296, 305, 298, 301, 305, 301, 301, 295, 302, 295, 300, 301, 298, 302, 303, 302, 300, 298, 297, 303, 295, 303, 301, 297, 298, 295, 301, 298, 298, 301, 302, 296, 298, 305, 295, 299, 295, 295, 303, 302, 304, 303, 304, 305, 299, 295, 305, 303, 300, 297, 300, 297, 305, 298, 297, 298, 305, 303, 302, 301, 299, 304] # 100 values for invalid online test

	for i in range(len(counter)):
		await FallingEdge(dut.clk)
		dut.raw_random_number.value = counter[i]
		dut.raw_random_valid.value = 1
		await FallingEdge(dut.clk)
		dut.raw_random_valid.value = 0
		await Signal.Skip(dut.clk, 10)
		if i > 10:
			assert dut.onlinetest_valid.value == 0, "Online test should be invalid"
	
	await Signal.Skip(dut.clk, 50)

@cocotb.test()
async def test_coso_alarm(dut):
	await cocotb.start(Clock(dut.clk, 10, units="ns").start())
	assert dut.alarm_detected.value == 0, "Alarm should not be raised"
	await Signal.Skip(dut.clk, 100)
	assert dut.alarm_detected.value == 1, "Alarm should be raised"
