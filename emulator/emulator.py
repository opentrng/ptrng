import numpy as np
import colorednoise as cn
import itertools

# Default noise amplitude factors for different frequencies
A1_F100M = 1.421672927151507e-13
A2_F100M = 1.155722907268553e-25
A1_F500M = 1.334028139656070e-14
A2_F500M = 7.985611510791367e-09

# Default number of periods to generate
GENPERIODS = int(10e6)

# Generate a time series of a number of periods from a noisy RO at given frequency
def generate_periods(periods, frequency, a1, a2):

	# Parameter conversion
	N = int(periods)
	T = 1 / frequency

	# Generate noise
	thermal = cn.powerlaw_psd_gaussian(0, N)
	flicker = cn.powerlaw_psd_gaussian(1, N)

	# Generate the time serie in femtosecond composed of thermal and flicker noises
	series = T*np.ones(N) + thermal*np.sqrt(a1*T) + flicker*np.sqrt(a2*(T**2))

	# Return the time serie composed of thermal and flicker noises
	return series

# Makes a frequency divisor for an input signal given as ro period series
def frequency_divider(ro, div):
	size = int(len(ro)/div)
	return np.sum(np.reshape(ro[:size*div], (size, div)), axis=1)

# Returns the absolute times for rising edges of a period series
def rising_edges(periods):
	return np.cumsum(periods)

# Returns the absolute times for rising and falling edges of a period series (assuming a 50% duty cycle)
def risingfalling_edges(periods):
	halfperiods1 = np.array(periods/2)
	halfperiods0 = periods - halfperiods1
	halfperiods = np.ravel((halfperiods1, halfperiods0), order='F')
	return np.cumsum(halfperiods)

# Sample the first digital signal (v0, v1) described in the input vector 'valuestimes' as the absolute time of its rising and falling edges. The sampling signal is given as 'samplingtimes' as the absolute times of its rising edges (for sampling).
def sampling(v0, v1, valuestimes, samplingtimes, ts=0, th=0):
	idx_v = 0 # start iterrator index for valuestimes
	len_v = len(valuestimes) # number of valuestimes (rising and falling edges)
	len_s = len(samplingtimes) # number of samples (sampling signal rising edges)
	samples = np.zeros(len_s) # output vector
	xsetup = np.zeros(len_s) # setup violations
	xhold = np.zeros(len_s) # hold violations

	# For each sampling time
	for idx_s in range(len_s):

		# Iterate over the valuestimes until the sampling time is older
		while idx_v < len_v and valuestimes[idx_v] < samplingtimes[idx_s]:
			idx_v += 1

		# Stop if no more values to sample
		if idx_v >= len_v:
			break

		# When the latest time of value is found, extract its level (v0, v1)
		samples[idx_s] = v0 if (idx_v-1)%2 == 0 else v1

		# Check for setup and hold violations
		if ts > 0:
			xsetup[idx_s] = 1 if valuestimes[idx_v-1]+ts>samplingtimes[idx_s] else 0
		if th > 0:
			xhold[idx_s] = 1 if valuestimes[idx_v]-th<samplingtimes[idx_s] else 0

	# The function returns the samples (v0, v1) and setup/hold violations
	return samples, xsetup, xhold

# Emulate a ERO entropy source with two ring oscillators 'ro1' and 'ro2/div', returns ERO random bits
def ero(ro1, ro2, div):
	# Divide RO2 frequency
	ro2div = frequency_divider(ro2, div)

	# Create the vectors of absolute times for RO1 edges (rising and falling) and RO2 rising edges
	valuestimes = risingfalling_edges(ro1)
	samplingtimes = rising_edges(ro2div)

	# Do the samping with edges times of RO1 and RO2
	bits, xsetup, xhold = sampling(0, 1, valuestimes, samplingtimes)

	# Return the random bit directly
	return bits

# Emulate a MURO entropy source with multiple ringos 'ro' sampled with 'ro2/div', returns MURO random bits
def muro(ro, ro2, div):
	# Generate rising edege times for RO2/div
	ro2div = frequency_divider(ro2, div)
	samplingtimes = rising_edges(ro2div)

	# Sample all ROs with RO2/div
	mbits = np.empty((0, len(ro2div)))
	for ro1 in ro:
		valuestimes = risingfalling_edges(ro1)
		bits, xsetup, xhold = sampling(0, 1, valuestimes, samplingtimes)
		mbits = np.vstack((mbits, bits))

	# TODO: also prepare the model for XORing ROs before sampling

	# Element wise XOR bits from all sampled RO
	return np.bitwise_xor.reduce(mbits.astype(int), axis=0)

# Emulate a COSO entropy source with two ring oscillators 'ro1' and 'ro2', returns COSO counter values
def coso(ro1, ro2):
	# Create the vectors of absolute times for RO1 edges (rising and falling) and RO2 rising edges
	valuestimes = risingfalling_edges(ro1)
	samplingtimes = rising_edges(ro2)

	# Do the samping with edges times of RO1 and RO2
	beat, xsetup, xhold = sampling(-1, 1, valuestimes, samplingtimes)

	# Count the consecutive lengths of '0' runs and '1' runs
	halfcounters = [sum(1 for _ in group) for sample, group in itertools.groupby(beat) if sample]
	halfsize = int(len(halfcounters)/2)

	# Sum '0' run lengths and '1' run lengths two-by-two in order to count 'beat' period size
	return np.sum(np.reshape(halfcounters[:halfsize*2], (halfsize, 2)), axis=1)
