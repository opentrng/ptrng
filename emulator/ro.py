import numpy as np
import argparse
import emulator

# Get command line arguments
parser = argparse.ArgumentParser(description="Generates a time series for a noisy ring oscillator. Default noise amplitudes and factors are suitable for a ring oscillator running around 500MHz. The script returns one period per line in femtosecond unit.")
parser.add_argument("periods", type=float, help="size of the time series in number of RO periods")
parser.add_argument("frequency", type=float, help="ring oscillator average frequency in Hz")
parser.add_argument("filename", type=str, help="output file (text format)")
parser.add_argument("-a1", type=float, default=emulator.A1_F500M, help="thermal noise amplitude factor")
parser.add_argument("-a2", type=float, default=emulator.A2_F500M, help="flicker noise amplitude factor")
args=parser.parse_args()

# Generate the time serie
series = emulator.generate_periods(args.periods, args.frequency, args.a1, args.a2)

# Output periods at femtosecond
np.savetxt(args.filename, series * 1e15, "%d")
