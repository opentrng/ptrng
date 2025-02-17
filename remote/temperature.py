import regmap as OpenTRNG
import fluart as Fluart
import argparse

# Function for reading the temperature
def read_temperature(reg):

	# Start the measurement
	reg.temperature_bf.start = 1

	# Wait until the measurement is done
	while reg.temperature_bf.done==0:
		True

	# Return the measured temperature
	return reg.temperature_bf.value * 503.975 / 4096 - 273.15

# Execute when the module is not initialized from an import statement
if __name__ == '__main__':

	# Get command line arguments
	parser = argparse.ArgumentParser(description="Read the die temperature.")
	parser.add_argument("-c", dest="count", required=False, type=int, default=1, help="number of successive values to measure")
	parser.add_argument("-q", "--quiet", action='store_true', help="quiet mode, only display the measured value")
	args=parser.parse_args()

	# Open and check the UART to the register map
	interface = Fluart.CmdProc()
	reg = OpenTRNG.RegMap(interface)
	interface.check(reg.id_bf.uid, reg.id_bf.rev)

	# Reset the PTRNG
	reg.control_bf.reset = 1

	# Enable the temperature sensor
	reg.temperature_bf.en = 1

	# Read the results
	count = 0
	while count<args.count or args.count==-1:
		count += 1

		# Read die temperature
		temp = read_temperature(reg)

		# Print the result
		if not args.quiet:
			print("Measured die temperature {:f}°C".format(temp))
		else:
			print(temp)
