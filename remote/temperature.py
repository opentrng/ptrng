import regmap as OpenTRNG
import fluart as Fluart
import argparse
import analog

# Get command line arguments
parser = argparse.ArgumentParser(description="Measure the die temperature.")
parser.add_argument("-c", dest="count", required=False, type=int, default=1, help="number of successive values to measure")
parser.add_argument("-q", "--quiet", action='store_true', help="quiet mode, only display the measured value")
args=parser.parse_args()

# Open and check the UART to the register map
interface = Fluart.CmdProc()
reg = OpenTRNG.RegMap(interface)
interface.check(reg.id_bf.uid, reg.id_bf.rev)

# Enable the analog sensors
reg.analog_bf.en = 1

# Read the results
count = 0
while count<args.count or args.count==-1:
	count += 1

	# Read the die temperature
	temperature, voltage = analog.read(reg)

	# Print the result
	if not args.quiet:
		print("Temperature {:f}°C".format(temperature))
	else:
		print(temperature)

