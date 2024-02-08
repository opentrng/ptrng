import numpy as np
import itertools
import argparse
import emulator

# Get command line arguments
parser = argparse.ArgumentParser(description="Emulates the ERO and generate a series of bits.")
parser.add_argument("-size", required=True, type=float, help="numer of bits to generate")
parser.add_argument("-freq0", required=True, type=float, help="base frequency (in Hz) of the sampling ring-oscillator (RO0)")
parser.add_argument("-freq1", required=True, type=float, help="frequency (in Hz) of the sampled ring-oscillator (RO1)")
parser.add_argument("-div", required=True, type=int, help="divisor for the sampling clock (sampling frequency will be RO0/div)")
parser.add_argument("-a1", type=float, default=emulator.A1_F500M, help="thermal noise amplitude factor (default {:e})".format(emulator.A1_F500M))
parser.add_argument("-a2", type=float, default=emulator.A2_F500M, help="flicker noise amplitude factor (default {:e})".format(emulator.A2_F500M))
parser.add_argument("filename", type=str, help="output file (text format)")
args=parser.parse_args()

# Command line argument summary
print("Number of bits to generate: {:.2e}".format(args.size))
print("Ring-oscillators frequencies:")
print(" - RO0: {:.3e} Hz / {:d}".format(args.freq0, args.div))
print(" - RO1: {:.3e} Hz".format(args.freq1))
print("Noise amplitude coefficiens:")
print(" - Thermal (a1): {:e}".format(args.a1))
print(" - Flicker (a2): {:e}".format(args.a2))

# Generate the ringos and emulate the ERO until the requested size is reached
bits = np.array([])
while len(bits) < int(args.size):
	ro0 = emulator.generate_periods(emulator.GENPERIODS, args.freq0, args.a1, args.a2)
	ro1 = emulator.generate_periods(emulator.GENPERIODS, args.freq1, args.a1, args.a2)
	bits = np.append(bits, emulator.ero(args.div, ro0, ro1))

# Give the raw bit bias
print("Output bits bias: {:.2f}".format(np.mean(bits)))

# Save the requested number of bits to a text file
np.savetxt(args.filename, bits[:int(args.size)], "%d")
