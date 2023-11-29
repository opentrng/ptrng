import numpy as np
import colorednoise as cn
import argparse

# Get command line arguments
parser = argparse.ArgumentParser(description="Generates a time series for a noisy ring oscillator. Default noise amplitudes and factors are suitable for a ring oscillator running around 500MHz. The script returns one period per line in femtosecond unit.")
parser.add_argument("periods", type=float, help="size of the time series in number of RO periods")
parser.add_argument("frequency", type=float, help="ring oscillator average frequency in Hz")
parser.add_argument("filename", type=str, help="output file (text format)")
parser.add_argument("-a1", type=float, default=2.56e-14, help="thermal noise amplitude")
parser.add_argument("-f1", type=float, default=1.919, help="thermal noise factor")
parser.add_argument("-a2", type=float, default=1.11e-09, help="flicker noise amplitude")
parser.add_argument("-f2", type=float, default=0.139, help="flicker noise factor")
args=parser.parse_args()

# Parameter conversion
N = int(args.periods)
T = 1 / args.frequency

# Generate noise
thermal = cn.powerlaw_psd_gaussian(0, N)
flicker = cn.powerlaw_psd_gaussian(1, N)

# Generate the time serie
series = T*np.ones(N) + thermal*np.sqrt(args.a1*T/args.f1) + flicker*np.sqrt(args.a2*(T**2)/args.f2)

# Output periods at femtosecond
np.savetxt(args.filename, series*1e15, "%.0f")
