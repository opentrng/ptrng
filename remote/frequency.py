import registers as OpenTRNG
import fluart as Fluart
import argparse

# Get command line arguments
parser = argparse.ArgumentParser(description="Measure the frequency of a ring oscillator.")
parser.add_argument("ro", type=int, help="index of the ring-oscillator (from 0 to 31)")
args=parser.parse_args()
assert args.ro in range(32)

# Open the UART to the register map
interface = Fluart.CmdProc()
reg = OpenTRNG.RegMap(interface)

# Reset and check the board
reg.control_bf.reset = 1
interface.check(reg.id_bf.uid, reg.id_bf.rev)

# Enable the RO
reg.ring_bf.enable = 1 << args.ro

# Reset and enable the frequency counter
reg.freqcount_bf.reset = 1
reg.freqcount_bf.en = 1

# Select the ring and start the measurement
reg.freqcount_bf.select = args.ro
reg.freqcount_bf.start = 1

# Wait until the measurement is done
while reg.freqcount_bf.done==0:
	True

# Print the result
print("Measured frequency for RO{:d}: {:f}MHz".format(args.ro, reg.freqcount_bf.result/10000))
print("Overflow: {:}".format(reg.freqcount_bf.overflow==1 if True else False))

# Disable all the ROs
reg.ring_bf.enable = 0x00000000
