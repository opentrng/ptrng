import numpy as np
import colorednoise as cn

# Default noise amplitude and factor for 500MHz
A1_F500M = 2.56e-14
F1_F500M = 1.919
A2_F500M = 1.11e-09
F2_F500M = 0.139

# Generate a time series of a number of periods from a noisy RO at given frequency (output unit femtosecond)
def generate_series(periods, frequency, a1=A1_F500M, f1=F1_F500M, a2=A2_F500M, f2=F2_F500M):

	# Parameter conversion
	N = int(periods)
	T = 1 / frequency

	# Generate noise
	thermal = cn.powerlaw_psd_gaussian(0, N)
	flicker = cn.powerlaw_psd_gaussian(1, N)

	# Generate the time serie in femtosecond composed of thermal and flicker noises
	series = T*np.ones(N) + thermal*np.sqrt(a1*T/f1) + flicker*np.sqrt(a2*(T**2)/f2)
	series *= 1e15

	# Return the time serie composed of thermal and flicker noises
	return series.astype(int)
