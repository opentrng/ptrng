import regmap as OpenTRNG
import fluart as Fluart
import argparse

# Get command line arguments
parser = argparse.ArgumentParser(description="Measure the frequency of a ring oscillator.")
parser.add_argument("-i", required=True, type=int, help="index of the ring-oscillator (from 0 to 31)")
args=parser.parse_args()
assert args.i in range(32)

# Open the UART to the register map
interface = Fluart.CmdProc()
reg = OpenTRNG.RegMap(interface)

# Reset and check the board
reg.control_bf.reset = 1
interface.check(reg.id_bf.uid, reg.id_bf.rev)

# Enable the RO
reg.ring_bf.en = 1 << args.i

# Reset and enable the frequency counter
reg.freq_bf.reset = 1
reg.freq_bf.en = 1

# Select the ring and start the measurement
reg.freq_bf.select = args.i
reg.freq_bf.start = 1

# Wait until the measurement is done
while reg.freq_bf.done==0:
	True

# Print the result
print("Measured frequency for RO{:d}: {:f}MHz".format(args.i, reg.freq_bf.value/10000))
print("Overflow: {:}".format(reg.freq_bf.overflow==1 if True else False))

# Disable all the ROs
reg.ring_bf.enable = 0x00000000
