import numpy as np
import itertools
import argparse
import emulator

# Get command line arguments
parser = argparse.ArgumentParser(description="Emulates the COSO entropy source and generate a series of counter values.")
parser.add_argument("size", type=float, help="numer of values to generate")
parser.add_argument("freq1", type=float, help="first ring oscillator frequency in Hz")
parser.add_argument("freq2", type=float, help="second ring oscillator frequency in Hz")
parser.add_argument("-a1", type=float, default=emulator.A1_F100M, help="thermal noise amplitude factor")
parser.add_argument("-a2", type=float, default=emulator.A2_F100M, help="flicker noise amplitude factor")
parser.add_argument("filename", type=str, help="output file (text format)")
args=parser.parse_args()

# Command line argument summary
print("Number of bits to generate: {:.2e}".format(args.size))
print("Ring-oscillators frequencies:")
print(" - RO1: {:.3e} Hz".format(args.freq1))
print(" - RO2: {:.3e} Hz".format(args.freq2))
print("Noise amplitude coefficiens:")
print(" - Thermal (a1): {:e}".format(args.a1))
print(" - Flicker (a2): {:e}".format(args.a2))

# Generate the ringos and emulate the COSO until the requested size is reached
values = np.array([])
while len(values) < int(args.size):
	ro1 = emulator.generate_periods(emulator.GENPERIODS, args.freq1, args.a1, args.a2)
	ro2 = emulator.generate_periods(emulator.GENPERIODS, args.freq2, args.a1, args.a2)
	values = np.append(values, emulator.coso(ro1, ro2))

# Give the mean value of counters
print("Average counter value: {:.2f}".format(np.mean(values)))

# Save the requested number of values to a text file
np.savetxt(args.filename, values[:int(args.size)], "%d")
