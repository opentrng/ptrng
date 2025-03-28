import numpy as np

# Encode the array of bits into an array of words ('wordlen' is the size of each word in bits)
def to_words(bits, wordlen):
	assert wordlen > 0 and wordlen <= 32
	if wordlen==1:
		return bits
	bitcount = bits.size - bits.size%wordlen
	wordcout = int(bitcount/wordlen)
	trucated = bits[:bitcount]
	reshaped = np.reshape(trucated, (wordcout, wordlen))
	padding = np.zeros((wordcout, 32-wordlen), dtype=int)
	words32bits = np.concatenate((padding, reshaped), axis=1)
	words4bytes = np.packbits(words32bits, axis=1)
	words = np.apply_along_axis(int.from_bytes, 1, words4bytes, byteorder='big', signed=False)
	return words

# Expand bytes to an array of bits
def to_bits(bytes):
	binary = bin(int.from_bytes(bytes, byteorder='big'))
	bits = np.array([int(binary[i]) for i in range(2, len(binary))])
	return bits
