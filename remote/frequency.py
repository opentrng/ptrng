import regmap as OpenTRNG
import fluart as Fluart
import argparse

# Get command line arguments
parser = argparse.ArgumentParser(description="Measure the frequency of a ring oscillator.")
parser.add_argument("-i", dest="index", required=True, type=int, help="index of the ring-oscillator (from 0 to 31)")
parser.add_argument("-c", dest="count", required=False, type=int, default=1, help="number of successive values to measure")
parser.add_argument("-q", "--quiet", action='store_true', help="quiet mode, only display the measured value")
args=parser.parse_args()
assert args.index in range(32)

# Open the UART to the register map
interface = Fluart.CmdProc()
reg = OpenTRNG.RegMap(interface)

# Reset and check the board
reg.control_bf.reset = 1
interface.check(reg.id_bf.uid, reg.id_bf.rev)

# Enable the RO
reg.ring_bf.en = 1 << args.index

# Reset and enable the frequency counter
reg.freqcount_bf.reset = 1
reg.freqcount_bf.en = 1

# Read the results
count = 0
while count<args.count or args.count==-1:
	count += 1

	# Select the ring and start the measurement
	reg.freqcount_bf.select = args.index
	reg.freqcount_bf.start = 1

	# Wait until the measurement is done
	while reg.freqcount_bf.done==0:
		True

	# Print the result
	if not args.quiet:
		print("Measured frequency for RO{:d}: {:f}MHz".format(args.index, reg.freqcount_bf.value/10000))
		print("Overflow: {:}".format(reg.freqcount_bf.overflow==1 if True else False))
	else:
		print(reg.freqcount_bf.value/10000)

# Disable all the ROs
reg.ring_bf.enable = 0x00000000
