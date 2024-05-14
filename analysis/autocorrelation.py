import matplotlib.pyplot as plt
import numpy as np
import argparse
import math
import binutils

# Compute the autocorrelation on the signal
def autocorr(samples, depth):
	assert depth <= samples.size/2
	lags = range(1, depth)
	result = np.array([np.count_nonzero(np.equal(samples, np.roll(samples, lag)) == True)/samples.size for lag in lags])
	return lags, result/samples.size

# When started from terminal
if __name__ == '__main__':

	# Get command line arguments
	parser = argparse.ArgumentParser(description="Plot the autocorrelation function.")
	parser.add_argument("-b", dest="n", type=int, default=1, help="samples are N bits words (default 1)")
	parser.add_argument("-d", dest="depth", type=int, default=100, help="autocorrelation depth or maximum lag (default 100))")
	parser.add_argument("-t", dest="title", type=str, default="", help="plot title")
	parser.add_argument("datafile", type=str, help="data input file (binary)")
	parser.add_argument("plotfile", type=str, help="plot output file (possibles extensions png, jpg, pdf)")
	args=parser.parse_args()

	# Load the data file and unpack bytes to bits
	data = np.fromfile(args.datafile, dtype='uint8')
	bits = np.unpackbits(data)

	# Compute the autocorrelation
	lags, acf = autocorr(binutils.to_words(bits, args.n), args.depth)

	# Plot the autocorrelation
	plt.title(args.title)
	plt.xlabel('Autocorrelation lag')
	plt.ylabel('Normalized correlation')
	plt.plot(acf*2**args.n)
	plt.savefig(args.plotfile)
