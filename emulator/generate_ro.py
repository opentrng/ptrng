import numpy as np
import colorednoise as cn
import sys

# Test command line arguments
if len(sys.argv)!=3 and len(sys.argv)!=7:
	print("Usage: python {:s} <Fc> <N> [<a1> <a2> <f1> <f2>]".format(sys.argv[0]))
	print("Generates a time serie of N cycles from an emulated noisy RO at average frequency Fc. Optionnaly Allan variance coefficients 'a' and noise facors 'f' can be specified for thermal '1' and flicker '2' noises. The script returns one period per line.")
	print("Example: '{:s} 500e6 10e3' will generate 10k cycles of a RO operating at 500MHz".format(sys.argv[0]))
	quit()

# Parameters
Fc = float(sys.argv[1])
N = int(float(sys.argv[2]))
T = 1 / Fc
if len(sys.argv)==7:
	a1 = float(sys.argv[3])
	a2 = float(sys.argv[4])
	f1 = float(sys.argv[5])
	f2 = float(sys.argv[6])
else:
	a1 = 2.81e-14
	a2 = 1.16e-10
	f1 = 2
	f2 = 0.135

# Generate noise
thermal = cn.powerlaw_psd_gaussian(0, N)
flicker = cn.powerlaw_psd_gaussian(1, N)

# Generate the time serie
serie = T*np.ones(N) + thermal*np.sqrt(a1*T/f1) + flicker*np.sqrt(a2*(T**2)/(f2**2))

# Output periods at femtosecond
for sample in serie:
	print("{:.0f} fs".format(sample*1e15))
