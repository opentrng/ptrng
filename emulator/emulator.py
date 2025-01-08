import numpy as np
import random as rnd
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
	thermal = cn.powerlaw_psd_gaussian(0, N) if a1 > 0 else np.zeros(N)
	flicker = cn.powerlaw_psd_gaussian(1, N) if a2 > 0 else np.zeros(N)

	# Generate the time series in second composed of thermal and flicker noises
	series = T*np.ones(N) + thermal*np.sqrt(a1*T) + flicker*np.sqrt(a2*(T**2))

	# Add an initial phase to the series
	init = T*rnd.random()
	series = np.insert(series[:-1], 0, init)

	# Return the series with a precision limited to femtosecond (to maintain compatibility with HDL simulators)
	limited = (series * 1e15).astype(int) * 1e-15
	return limited

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
def sampling(v0, v1, valuestimes, samplingtimes, ts=0, th=0, metabias=0.5):
	idx_v = 0 # start iterrator index for valuestimes
	len_v = len(valuestimes) # number of valuestimes (rising and falling edges)
	len_s = len(samplingtimes) # number of samples (sampling signal rising edges)
	samples = np.zeros(len_s) # output bits
	valid = np.ones(len_s) # valid timing constraints
	resolved = np.zeros(len_s) # resolved metastable bits
	setup = np.zeros(len_s) # setup violations
	hold = np.zeros(len_s) # hold violations
	len_b = len_s # final count of sampled bits

	# For each sampling time
	for idx_s in range(len_s):

		# Iterate over the valuestimes until the sampling time is older
		while idx_v < len_v and valuestimes[idx_v] < samplingtimes[idx_s]:
			idx_v += 1

		# Stop if no more values to sample
		if idx_v >= len_v:
			len_b = idx_s-1
			break

		# When the latest time of value is found, extract its level (v0, v1)
		samples[idx_s] = v0 if idx_v%2 == 0 else v1

		# Check for setup violations
		setup[idx_s] = 1 if ts > 0 and valuestimes[idx_v-1]+ts > samplingtimes[idx_s] else 0
		
		# Check for hold violations
		hold[idx_s] = 1 if th > 0 and valuestimes[idx_v]-th < samplingtimes[idx_s] else 0

		# Unvalidate output if violations has been detected
		if setup[idx_s] == 1 or hold[idx_s] == 1:
			valid[idx_s] = 0
		
		# Resolve metastability in case of timing violation
		if valid[idx_s] == 0:
			resolved[idx_s] = 0 #v1 if rnd.random() > metabias else v0
		else:
			resolved[idx_s] = samples[idx_s]

	# The function returns the samples (v0, v1) and the verifications of timing constraints
	return samples[:len_b].astype(int), valid[:len_b].astype(int), resolved[:len_b].astype(int)

# Emulate a ERO entropy source with two ring oscillators 'ro1' sampled by 'ro0/div', returns ERO random bits
def ero(div, ro0, ro1, ts=0, th=0, metabias=0.5):
	# Divide RO0 frequency
	ro0div = frequency_divider(ro0, div)

	# Create the vectors of absolute times for RO1 edges (rising and falling) and RO0/div rising edges
	valuestimes = risingfalling_edges(ro1)
	samplingtimes = rising_edges(ro0div)

	# Do the samping with edges times
	bits, valid, resolved = sampling(0, 1, valuestimes, samplingtimes, ts, th, metabias)

	# Return the random bit directly
	return bits, valid, resolved

# Emulate a MURO entropy source with multiple ringos 'ro[x]' sampled with 'ro0/div', returns MURO random bits
def muro(div, ro0, rox, ts=0, th=0, metabias=0.5):
	# Generate rising edege times for RO0/div
	ro0div = frequency_divider(ro0, div)
	samplingtimes = rising_edges(ro0div)
	count = len(ro0div)
	minlen = count

	# Sample all ROx with RO0/div
	mbits = np.empty((0, count))
	mvalid = np.empty((0, count))
	mresolved = np.empty((0, count))
	for ro in rox:
		valuestimes = risingfalling_edges(ro)
		bits, valid, resolved = sampling(0, 1, valuestimes, samplingtimes, ts, th, metabias)
		mbits = np.vstack((mbits, np.pad(bits, (0, count-len(bits)))))
		mvalid = np.vstack((mvalid, np.pad(valid, (0, count-len(valid)))))
		mresolved = np.vstack((mresolved, np.pad(resolved, (0, count-len(valid)))))
		minlen = min(len(bits), minlen)

	# Element wise XOR bits from all sampled RO
	bits = np.bitwise_xor.reduce(mbits.astype(int), axis=0)
	valid = np.sum(mvalid.astype(int), axis=0)
	resolved = np.bitwise_xor.reduce(mresolved.astype(int), axis=0)
	
	# Truncate to the lower generated boundary
	return bits[:minlen], valid[:minlen], resolved[:minlen]

# Emulate a COSO entropy source with two ring oscillators 'ro1' sampled by 'ro0', returns COSO counter values
def coso(ro0, ro1, full=True, threshold=0):
	# Create the vectors of absolute times for RO1 edges (rising and falling) and RO0 rising edges
	valuestimes = risingfalling_edges(ro1)
	samplingtimes = rising_edges(ro0)

	# Do the samping with edges times
	beat, valid, resolved = sampling(-1, 1, valuestimes, samplingtimes)

	# Count the consecutive lengths of '0' runs and '1' runs
	halfcounters = np.array([sum(1 for _ in group) for sample, group in itertools.groupby(beat) if sample])
	halfcounters = halfcounters[halfcounters >= threshold]
	halfsize = int(len(halfcounters)/2)

	# Do the same for resolved values
	halfresolved = [sum(1 for _ in group) for sample, group in itertools.groupby(resolved) if sample]

	# For the full COSO, sum half values by two
	if full:
		return np.sum(np.reshape(halfcounters[:halfsize*2], (halfsize, 2)), axis=1)
	
	# For the half COSO keep values for half periods as key are
	else:
		return halfcounters
