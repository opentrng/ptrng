import regmap as OpenTRNG
import fluart as Fluart
import argparse

# Function for reading temperature and voltage
def read(reg):
	temperature = reg.analog_bf.temperature * 503.975 / 4096 - 273.15
	voltage = reg.analog_bf.voltage * 3 / 4096
	return temperature, voltage

# Execute when the module is not initialized from an import statement
if __name__ == '__main__':

	# Get command line arguments
	parser = argparse.ArgumentParser(description="Read analog temperature and voltage")
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
	reg.analog_bf.en = 1

	# Read the results
	count = 0
	while count<args.count or args.count==-1:
		count += 1

		# Read temperature and voltage
		temperature, voltage = read(reg)

		# Print the result
		if not args.quiet:
			print("Temperature {:f}°C".format(temperature))
			print("Voltage {:f}V".format(voltage))
		else:
			print(temperature, voltage)

