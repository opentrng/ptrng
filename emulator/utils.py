import numpy as np
import colorednoise as cn
import itertools

# Default noise amplitude factors for different frequencies
A1_F100M = 1.421672927151507e-13
A2_F100M = 1.155722907268553e-25
A1_F500M = 1.334028139656070e-14
A2_F500M = 7.985611510791367e-09

# Generate a time series of a number of periods from a noisy RO at given frequency (output unit femtosecond)
def generate_periods(periods, frequency, a1=A1_F500M, a2=A2_F500M):

	# Parameter conversion
	N = int(periods)
	T = 1 / frequency

	# Generate noise
	thermal = cn.powerlaw_psd_gaussian(0, N)
	flicker = cn.powerlaw_psd_gaussian(1, N)

	# Generate the time serie in femtosecond composed of thermal and flicker noises
	series = T*np.ones(N) + thermal*np.sqrt(a1*T) + flicker*np.sqrt(a2*(T**2))
	series *= 1e15

	# Return the time serie composed of thermal and flicker noises
	return series.astype(int)

# Sample the first digital signal (0, 1) described in the input vector 'valuestimes' as the absolute time of its rising and falling edges. The sampling signal is depicted in 'samplingtimes' as the absolute times of its rising edges (for sampling).
def sampling(valuestimes, samplingtimes):
	idx_v = 0 # start iterrator index for valuestimes
	len_v = len(valuestimes) # number of valuestimes (rising and falling edges)
	len_s = len(samplingtimes) # number of samples (sampling signal rising edges)
	samples = np.zeros(len_s) # output vector

	# For each sampling time
	for idx_s in range(len_s):

		# Iterate over the valuestimes until the sampling time is older
		while valuestimes[idx_v] < samplingtimes[idx_s]:
			idx_v += 1
			if idx_v >= len_v:
				return samples

		# When the latest time of value is found, extract its level (0, 1)
		samples[idx_s] = 1 if (idx_v-1)%2 == 0 else -1

	# The function returns all the samples (0, 1)
	return samples

# Emulate a COSO entropy source with 'n' periods of two ringos at frequency 'f1' and 'f2' and returns COSO counter values
def coso(n, f1, f2, a1=A1_F500M, a2=A2_F500M):
	# Generate 'n' periods of signal for ring-oscillators 1 and 2
	ro1 = generate_periods(n, f1, a1, a2)
	ro2 = generate_periods(n, f2, a1, a2)

	# Reshape RO1 periods to RO1 half-periods (assuming a 50% duty cycle)
	halfperiods_high = np.array(ro1/2).astype(int)
	halfperiods_low = ro1 - halfperiods_high
	halfperiods = np.ravel((halfperiods_high, halfperiods_low), order='F')

	# Create the vectors of absolute times for RO1 edges (rising and falling) and RO2 rising edges
	valuestimes = np.cumsum(halfperiods)
	samplingtimes = np.cumsum(ro2)
	assert np.array_equal(valuestimes[1::2], np.cumsum(ro1))

	# Do the samping with edges times of RO1 and RO2
	beat = sampling(valuestimes, samplingtimes)

	# Count the consecutive lengths of '0' runs and '1' runs
	halfcounters = [sum(1 for _ in group) for sample, group in itertools.groupby(beat) if sample]
	halfsize = int(len(halfcounters)/2)

	# Sum '0' run lengths and '1' run lengths two-by-two in order to count 'beat' period size
	return np.sum(np.reshape(halfcounters[:halfsize*2], (halfsize, 2)), axis=1)
