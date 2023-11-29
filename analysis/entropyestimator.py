import matplotlib.pyplot as plt
import numpy as np
import argparse
import math

# Encode the array of bits into an array of words ('wordlen' is the size of each word in bits)
def to_words(bits, wordlen):
	assert wordlen > 0 and wordlen <= 32
	bitcount = bits.size - bits.size%wordlen
	wordcout = int(bitcount/wordlen)
	trucated = bits[:bitcount]
	reshaped = np.reshape(trucated, (wordcout, wordlen))
	padding = np.zeros((wordcout, 32-wordlen), dtype=int)
	words32bits = np.concatenate((padding, reshaped), axis=1)
	words4bytes = np.packbits(words32bits, axis=1)
	words = np.apply_along_axis(int.from_bytes, 1, words4bytes, byteorder='big', signed=False)
	return words

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
def markov(samples):
	values, counts = np.unique(samples, return_counts=True)
	assert np.array_equal(values, np.array([0, 1]))==True
	P0 = counts[0] / samples.size
	P1 = counts[1] / samples.size
	P = np.zeros((2, 2))
	for i in range(1, samples.size):
		P[samples[i-1], samples[i]] += 1
	P /= samples.size/2
	probabilities = np.array([
		P0*P[0,0]**127,
		P0*P[0,1]**64*P[1,0]**63,
		P0*P[0,1]*P[1,1]**126,
		P1*P[1,0]*P[0,0]**126,
		P1*P[1,0]**64*P[0,1]**63,
		P1*P[1,1]**127
		])
	return min(-math.log2(np.max(probabilities))/128, 1)

# Get command line arguments
parser = argparse.ArgumentParser(description="Compute the entropy for a binary file.")
parser.add_argument("file", type=str, help="data input file (binary)")
parser.add_argument("estimator", type=str, choices=['shannon', 'mcv', 'markov'], help="entropy estimator")
parser.add_argument("-b", dest="n", type=int, default=1, help="estimate with N bits samples")
args=parser.parse_args()

# Test arguments
if args.estimator=="markov" and args.n>1:
	print("ERROR: cannot compute Markov estimator on n>1 bit words")
	exit(-1)

# Load the data file and unpack bytes to bits
data = np.fromfile(args.file, dtype='uint8')
bits = np.unpackbits(data)
words = to_words(bits, args.n)

# Compute estimators
if args.estimator=="shannon":
	entropy = shannon(words)
if args.estimator=="mcv":
	entropy = mcv(words)
if args.estimator=="markov":
	entropy = markov(bits)

# Output
print("Entropy computed with {:s} estimator on {:d} bits samples: {:.12f}".format(args.estimator, args.n, entropy))
