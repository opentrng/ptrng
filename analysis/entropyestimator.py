import matplotlib.pyplot as plt
import numpy as np
import math
import sys

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

# Compute the autocorrelation on the signal
def autocorr(samples):
	result = np.zeros(samples.size);
	mean = np.mean(samples)
	lags = range(1, samples.size)
	result = np.array([np.count_nonzero(np.equal(samples, np.roll(samples, lag)) == True) for lag in lags])
	return result/samples.size

# Test command line arguments
if len(sys.argv)!=2:
	print("Usage: python {:s} <file>".format(sys.argv[0]))
	print("Compute the entroepy of a binary respresentation text <file> with the MCV estimator. The input file must contain one character 0 or 1 per line.")
	quit()

# Get parameters
file = sys.argv[1]

# Load the data file and unpack bytes to bits
data = np.fromfile(file, dtype='uint8')
bits = np.unpackbits(data)

for length in np.logspace(1, 4, 20).astype(int):
	fig = plt.figure()
	plt.title("Autocorr length={:}".format(length))
	plt.xlabel('x')
	plt.ylabel('AC%')
	legends = np.array([])
	for wordlen in range(1, 8+1):
		words = to_words(bits[:wordlen*length], wordlen)
		ac = autocorr(words)
		print("length={:} wordlen={:} max={:} avg={:}".format(length, wordlen, np.max(ac), np.avg(ac)))
		plt.plot(ac)
		legends = np.append(legends, "{:}bits".format(wordlen))
	plt.legend(legends)
	plt.savefig("autocorr_length{:05d}.png".format(length))
essayer de voir ce qui se passe quand on fait pareil mais avec un offset dans les bits
https://blocnotes.iergo.fr/breve/mode-mediane-moyenne-variance-et-ecart-type/
Mode : Le mode est la valeur la plus fréquente dans un échantillon.
Médiane : la médiane est un nombre qui divise en 2 parties la population telle que chaque partie contient le même nombre de valeurs. Dans la même logique, il y a les quartiles, déciles et centiles, qui divisent respectivement en 4, 10 et 100 la population.
Moyenne : La moyenne arithmétique est la somme des valeurs de la variable divisée par le nombre d’individus.
La variance : La variance est la moyenne des carrés des écarts à la moyenne.
L’écart-type : c’est la racine carrée de la variance.
quit()

data_wordlen = np.array([])
data_shanon = np.array([])
data_mcv = np.array([])
data_markov = np.array([])

for wordlen in range(1, 32+1):
	words = to_words(bits, wordlen)

	# values, counts = np.unique(words, return_counts=True)
	# print("{:d} values ({:d} expected -> {:s})".format(values.size, 2**wordlen, str(values.size==2**wordlen)))
	# fig = plt.figure()
	# plt.title('Distribution')
	# plt.xlabel('x')
	# plt.ylabel('N(x)')
	# # plt.bar(values, probabilities)
	# plt.ylim(0, np.max(counts))
	# plt.scatter(values, counts, marker='+')
	# plt.savefig("distribution_{:02d}bits.png".format(wordlen))

	# ac = autocorr(words)
	# fig = plt.figure()
	# plt.title('Autocorrelation')
	# plt.xlabel('lag')
	# plt.ylabel('AC')
	# plt.plot(ac)
	# plt.savefig("autocorr_{:02d}bits.png".format(wordlen))

	# print("Autocor {:d}bits: {:.12f}".format(wordlen, np.max(ac)))

	shanon_entropy = shannon(words)/wordlen
	mcv_entropy = mcv(words)/wordlen
	
	print("Shannon {:d}bits: {:.12f}".format(wordlen, shanon_entropy))
	print("MCV est {:d}bits: {:.12f}".format(wordlen, mcv_entropy))
	if wordlen==1:
		print("Markov  {:d}bits: {:.12f}".format(1, markov(words)))
	
	data_wordlen = np.append(data_wordlen, wordlen)
	data_shanon = np.append(data_shanon, shanon_entropy)
	data_mcv = np.append(data_mcv, mcv_entropy)
	
fig = plt.figure()
plt.title('Entropy estimators')
plt.xlabel('Word length (bit)')
plt.ylabel('Entropy')
plt.plot(data_wordlen, data_shanon)
plt.plot(data_wordlen, data_mcv)
plt.legend(['Shannon', 'MCV'])
plt.savefig("entropy.png")


# for wordlen in range(1, 32+1):
# 	print(wordlen)

# 	words = to_words(bits, wordlen)
# 	values, counts = np.unique(np.diff(words), return_counts=True)
# 	fig = plt.figure()
# 	plt.title('Distribution')
# 	plt.xlabel('x')
# 	plt.ylabel('N(x)')
# 	# plt.bar(values, probabilities)
# 	plt.ylim(0, np.max(counts))
# 	plt.scatter(values, counts, marker='+')
# 	plt.savefig("diffdistrib_{:02d}bits.png".format(wordlen))

# 	values, counts = np.unique(words, return_counts=True)
# 	P = np.zeros((2**wordlen, 2**wordlen))
# 	for i in range(1, words.size):
# 		P[words[i-1], words[i]] += 1
# 	P /= words.size/2

# 	fig = plt.figure()
# 	plt.title('Transitions proba')
# 	plt.xlabel('x')
# 	plt.ylabel('x+1')
# 	plt.imshow(P)
# 	plt.savefig("transitions_{:02d}bits.png".format(wordlen))
