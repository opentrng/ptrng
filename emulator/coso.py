import numpy as np
import itertools
import argparse
import utils

# Get command line arguments
parser = argparse.ArgumentParser(description="")
parser.add_argument("size", type=float, help="numer of values to generate")
parser.add_argument("freq1", type=float, help="first ring oscillator average frequency in Hz")
parser.add_argument("freq2", type=float, help="second ring oscillator average frequency in Hz")
parser.add_argument("-a1", type=float, default=utils.A1_F100M, help="thermal noise amplitude factor")
parser.add_argument("-a2", type=float, default=utils.A2_F100M, help="flicker noise amplitude factor")
parser.add_argument("filename", type=str, help="output file (text format)")
args=parser.parse_args()

# Emulate the COSO until the requested size is reached
values = np.array([])
while len(values) < int(args.size):
	values = np.append(values, utils.coso(10e6, args.freq1, args.freq2, args.a1, args.a2))

# Save the requested number of values to a text file
np.savetxt(args.filename, values[:int(args.size)], "%d")
