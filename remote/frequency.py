import regmap as OpenTRNG
import fluart as Fluart
import argparse
import analog
import time

# Function for reading the frequency
def read(reg, index):

	# Select the ring and start the measurement
	reg.freqctrl_bf.select = index
	reg.freqctrl_bf.start = 1

	# Wait until the measurement is done
	while reg.freqctrl_bf.done==0:
		True

	# Return the measured frequency
	return reg.freqvalue_bf.value / 200_000

# Execute when the module is not initialized from an import statement
if __name__ == '__main__':

	# Get command line arguments
	parser = argparse.ArgumentParser(description="Measure the frequency of a ring oscillator.")
	parser.add_argument("-i", dest="index", required=True, type=int, help="index of the ring-oscillator (from 0 to 31)")
	parser.add_argument("-c", dest="count", required=False, type=int, default=1, help="number of successive values to measure")
	parser.add_argument("-q", "--quiet", action='store_true', help="quiet mode, only display the measured value")
	args=parser.parse_args()
	assert args.index in range(32)

	# Open and check the UART to the register map
	interface = Fluart.CmdProc()
	reg = OpenTRNG.RegMap(interface)
	interface.check(reg.id_bf.uid, reg.id_bf.rev)

	# Reset the PTRNG
	reg.control_bf.reset = 1

	# Enable the RO
	reg.ring_bf.en = 1 << args.index

	# Enable the frequency counter and analog sensors
	reg.freqctrl_bf.en = 1
	reg.analog_bf.en = 1

	# Read the results
	count = 0
	while count<args.count or args.count==-1:
		count += 1

		# Read RO frequency and die temperature
		frequency = read(reg, args.index)
		temperature, voltage = analog.read(reg)

		# Print the result
		if not args.quiet:
			print("Measured frequency for RO{:d}: {:f}MHz (overflow {:})".format(args.index, frequency, reg.freqctrl_bf.overflow==1 if True else False))
			print("Temperature {:f}°C".format(temperature))
			print("Voltage {:f}V".format(voltage))
		else:
			print(time.time(), frequency, temperature, voltage)

	# Disable all the ROs
	reg.ring_bf.en = 0x00000000

