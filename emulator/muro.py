import numpy as np
import itertools
import argparse
import emulator

# Get command line arguments
parser = argparse.ArgumentParser(description="Emulates the MURO and generate a series of bits.")
parser.add_argument("-size", required=True, type=float, help="numer of bits to generate")
parser.add_argument("-freq", required=True, type=float, nargs='+', help="frequency (in Hz) of the ring-oscillators RO0 to ROt")
parser.add_argument("-div", required=True, type=int, help="divisor for the sampling clock (sampling frequency will be RO0/div)")
parser.add_argument("-a1", type=float, default=emulator.A1_F100M, help="thermal noise amplitude factor (default {:e})".format(emulator.A1_F100M))
parser.add_argument("-a2", type=float, default=emulator.A2_F100M, help="flicker noise amplitude factor (default {:e})".format(emulator.A2_F100M))
parser.add_argument("filename", type=str, help="output file (text format)")
args=parser.parse_args()

# Command line argument summary
print("Number of bits to generate: {:.2e}".format(args.size))
print("Number of ring-oscillators: {:d} (t={:d})".format(len(args.freq), len(args.freq)-1))
print("Ring-oscillators frequencies:")
print(" - RO0: {:.3e} Hz / {:d}".format(args.freq[0], args.div))
print(" - RO1-ROt: {:s} Hz".format(', '.join(map("{:.3e}".format, args.freq[1:]))))
print("Noise amplitude coefficiens:")
print(" - Thermal (a1): {:e}".format(args.a1))
print(" - Flicker (a2): {:e}".format(args.a2))

# Generate the ringos and emulate the MURO until the requested size is reached
bits = np.array([])
while len(bits) < int(args.size):
	ro0 = emulator.generate_periods(emulator.GENPERIODS, args.freq[0], args.a1, args.a2)
	rox = np.empty((0, emulator.GENPERIODS))
	for f in args.freq[1:]:
		ro = emulator.generate_periods(emulator.GENPERIODS, f, args.a1, args.a2)
		rox = np.vstack((rox, ro))
	b, v, r = emulator.muro(args.div, ro0, rox)
	bits = np.append(bits, b)

# Give the raw bit bias
print("Output bits bias: {:.2f}".format(np.mean(bits)))

# Save the requested number of bits to a text file
np.savetxt(args.filename, bits[:int(args.size)], "%d")
