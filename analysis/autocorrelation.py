import matplotlib.pyplot as plt
import numpy as np
import argparse
import math
import binutils

# Compute the autocorrelation on the signal
def autocorr(samples, depth):
	assert depth <= samples.size/2
	lags = range(1, depth)
	result = np.array([np.count_nonzero(np.equal(samples, np.roll(samples, lag)) == True) for lag in lags])
	return result/samples.size

# Get command line arguments
parser = argparse.ArgumentParser(description="Plot the autocorrelation function.")
parser.add_argument("datafile", type=str, help="data input file (binary)")
parser.add_argument("plotfile", type=str, help="plot output file (possibles extensions png, jpg, pdf)")
parser.add_argument("-b", dest="n", type=int, default=1, help="samples are N bits words")
parser.add_argument("-d", dest="depth", type=int, default=100, help="autocorrelation depth (i.e. maximum lag)")
parser.add_argument("-t", dest="title", type=str, default="", help="plot title")
args=parser.parse_args()

# Load the data file and unpack bytes to bits
data = np.fromfile(args.datafile, dtype='uint8')
bits = np.unpackbits(data)

# Plot the autocorrelation
plt.title(args.title)
plt.xlabel('Autocorrelation lag')
plt.ylabel('Normalized correlation')
plt.plot(autocorr(binutils.to_words(bits, args.n), args.depth)*2**args.n)
plt.savefig(args.plotfile)
