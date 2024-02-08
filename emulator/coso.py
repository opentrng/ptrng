import numpy as np
import itertools
import argparse
import emulator

# Get command line arguments
parser = argparse.ArgumentParser(description="Emulates the COSO and generate a series of counter values.")
parser.add_argument("-size", required=True, type=float, help="numer of values to generate")
parser.add_argument("-freq0", required=True, type=float, help="frequency (in Hz) of the sampling ring-oscillator (RO0)")
parser.add_argument("-freq1", required=True, type=float, help="frequency (in Hz) of the sampled ring-oscillator (RO1)")
parser.add_argument("-a1", type=float, default=emulator.A1_F500M, help="thermal noise amplitude factor (default {:e})".format(emulator.A1_F500M))
parser.add_argument("-a2", type=float, default=emulator.A2_F500M, help="flicker noise amplitude factor (default {:e})".format(emulator.A2_F500M))
parser.add_argument("filename", type=str, help="output file (text format)")
args=parser.parse_args()

# Command line argument summary
print("Number of bits to generate: {:.2e}".format(args.size))
print("Ring-oscillators frequencies:")
print(" - RO0: {:.3e} Hz".format(args.freq0))
print(" - RO1: {:.3e} Hz".format(args.freq1))
print("Noise amplitude coefficiens:")
print(" - Thermal (a1): {:e}".format(args.a1))
print(" - Flicker (a2): {:e}".format(args.a2))

# Generate the ringos and emulate the COSO until the requested size is reached
values = np.array([])
while len(values) < int(args.size):
	ro0 = emulator.generate_periods(emulator.GENPERIODS, args.freq0, args.a1, args.a2)
	ro1 = emulator.generate_periods(emulator.GENPERIODS, args.freq1, args.a1, args.a2)
	values = np.append(values, emulator.coso(ro0, ro1))

# Give the mean value of counters
print("Average counter value: {:.2f}".format(np.mean(values)))
print("Output bits bias: {:.2f}".format(np.mean(values%2==0)))

# Save the requested number of values to a text file
np.savetxt(args.filename, values[:int(args.size)], "%d")
