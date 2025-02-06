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

# Open and check the UART to the register map
interface = Fluart.CmdProc()
reg = OpenTRNG.RegMap(interface)
interface.check(reg.id_bf.uid, reg.id_bf.rev)

# Reset the PTRNG
reg.control_bf.reset = 1

# Enable the RO
reg.ring_bf.en = 1 << args.index

# Reset and enable the frequency counter
reg.freqctrl_bf.reset = 1
reg.freqctrl_bf.en = 1

# Division factor depending on system clock
F = 100000.0

# Read the results
count = 0
while count<args.count or args.count==-1:
	count += 1

	# Select the ring and start the measurement
	reg.freqctrl_bf.select = args.index
	reg.freqctrl_bf.start = 1

	# Wait until the measurement is done
	while reg.freqctrl_bf.done==0:
		True

	# Print the result
	if not args.quiet:
		print("Measured frequency for RO{:d}: {:f}MHz".format(args.index, reg.freqvalue_bf.value/F))
		print("Overflow: {:}".format(reg.freqctrl_bf.overflow==1 if True else False))
	else:
		print(reg.freqvalue_bf.value/F)

# Disable all the ROs
reg.ring_bf.en = 0x00000000
