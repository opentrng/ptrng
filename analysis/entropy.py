import matplotlib.pyplot as plt
import numpy as np
import argparse
import math
import binutils

# Shannon entropy
def shannon(samples):
	values, counts = np.unique(samples, return_counts=True)
	probabilities = counts / samples.size
	plog2p = np.array([p*math.log2(p) for p in probabilities])
	return np.sum(-plog2p)

# Most Common Value entropy estimator
def mcv(samples):
	values, counts = np.unique(samples, return_counts=True)
	zalpha = 2.5758293035489008
	mode = np.max(counts)
	pmax = mode/samples.size
	ubound = min(1, pmax+zalpha*math.sqrt(pmax*(1.0-pmax)/(samples.size-1)))
	entropy = -math.log2(ubound);
	return entropy

# The Markov Estimate (only works on bit series)
def markov(bits):
	values, counts = np.unique(bits, return_counts=True)
	assert np.array_equal(values, np.array([0, 1]))==True
	P0 = counts[0] / bits.size
	P1 = counts[1] / bits.size
	P = np.zeros((2, 2))
	for i in range(1, bits.size):
		P[bits[i-1], bits[i]] += 1
	P /= bits.size/2
	probabilities = np.array([
		P0*P[0,0]**127,
		P0*P[0,1]**64*P[1,0]**63,
		P0*P[0,1]*P[1,1]**126,
		P1*P[1,0]*P[0,0]**126,
		P1*P[1,0]**64*P[0,1]**63,
		P1*P[1,1]**127
		])
	return min(-math.log2(np.max(probabilities))/128, 1)

# The T8 estimator (only works on bit series), credits B. Colombier (https://gitlab.com/BColombier/ais-31-statistical-tests)
def t8(bits):
	L = 8
	Q = 2560
	K = 256000
	if len(bits) < (Q+K)*L:
		raise ValueError("Not enough data to perform entropy estimation")
	byte_sequence = np.packbits(bits[:(Q+K)*L])
	last_pos = np.zeros(256, dtype='uint32')
	g_vals = np.ones(256000, dtype='float64')
	T = 0.0
	for index, byte in enumerate(byte_sequence):
		if last_pos[byte] != 0:
			gap = index-last_pos[byte]
			if gap > len(g_vals):
				raise ValueError("No precomputed g_val for this gap, you should increase the size of the g_vals array (currently {})".format(len(g_vals)))
			if index >= Q:
				if g_vals[gap] == 1:
					g_vals[gap] = (1/np.log(2))*np.sum([1/i for i in range(1, gap)])
				T += g_vals[gap]
		last_pos[byte] = index
	if index+1 != (Q+K):
		raise ValueError("Not enough data to perform entropy estimation")
	return T/K

# When started from terminal
if __name__ == '__main__':

	# Get command line arguments
	parser = argparse.ArgumentParser(description="Compute the entropy for a binary file.")
	parser.add_argument("-e", required=True, dest="estimator", type=str, choices=['shannon', 'mcv', 'markov', 't8'], help="entropy estimator")
	parser.add_argument("-b", dest="n", type=int, default=1, help="estimate with N bits samples (default 1)")
	parser.add_argument("-q", "--quiet", action='store_true', help="quiet mode, only display the measured value")
	parser.add_argument("file", type=str, help="data input file (binary)")
	args=parser.parse_args()

	# Test arguments
	if args.estimator=="markov" and args.n>1:
		print("ERROR: cannot compute Markov estimator on n>1 bit words")
		exit(-1)
	if args.estimator=="t8" and args.n!=8:
		print("ERROR: can compute T8 estimator on 8 bit words only")
		exit(-1)

	# Load the data file and unpack bytes to bits
	data = np.fromfile(args.file, dtype='uint8')
	bits = np.unpackbits(data)

	# Compute estimators
	if args.estimator=="shannon":
		entropy = shannon(binutils.to_words(bits, args.n))
	if args.estimator=="mcv":
		entropy = mcv(binutils.to_words(bits, args.n))
	if args.estimator=="markov":
		entropy = markov(bits)
	if args.estimator=="t8":
		entropy = t8(bits)

	# Output
	if args.quiet:
		print(entropy)
	else:
		print("Entropy computed with {:s} estimator on {:d} bits samples: {:.12f}".format(args.estimator, args.n, entropy))
