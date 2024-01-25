import numpy as np
import itertools
import argparse
import emulator

# Get command line arguments
parser = argparse.ArgumentParser(description="Emulates the MURO entropy source and generate a series of bits.")
parser.add_argument("size", type=float, help="numer of bits to generate")
parser.add_argument("freq1", type=float, nargs='+', help="first set of ring oscillators frequency in Hz")
parser.add_argument("freq2", type=float, help="second ring oscillator frequency in Hz")
parser.add_argument("div", type=int, help="divisor for the sampling clock (freq2)")
parser.add_argument("-a1", type=float, default=emulator.A1_F100M, help="thermal noise amplitude factor")
parser.add_argument("-a2", type=float, default=emulator.A2_F100M, help="flicker noise amplitude factor")
parser.add_argument("filename", type=str, help="output file (text format)")
args=parser.parse_args()

# Command line argument summary
print("Number of bits to generate: {:.2e}".format(args.size))
print("Ring-oscillators frequencies:")
print(" - Multiple RO1: {:s} Hz".format(', '.join(map("{:.3e}".format, args.freq1))))
print(" - RO2: {:.3e} Hz".format(args.freq2))
print("RO2 frequency divider: {:d}".format(args.div))
print("Noise amplitude coefficiens:")
print(" - Thermal (a1): {:e}".format(args.a1))
print(" - Flicker (a2): {:e}".format(args.a2))

# Generate the ringos and emulate the MURO until the requested size is reached
bits = np.array([])
while len(bits) < int(args.size):
	mro1 = np.empty((0, emulator.GENPERIODS))
	for f1 in args.freq1:
		ro1 = emulator.generate_periods(emulator.GENPERIODS, f1, emulator.A1_F100M, emulator.A2_F100M)
		mro1 = np.vstack((mro1, ro1))
	ro2 = emulator.generate_periods(emulator.GENPERIODS, args.freq2, args.a1, args.a2)
	bits = np.append(bits, emulator.muro(mro1, ro2, args.div))

# Give the raw bit bias
print("Output bits bias: {:.2f}".format(np.mean(bits)))

# Save the requested number of bits to a text file
np.savetxt(args.filename, bits[:int(args.size)], "%d")
