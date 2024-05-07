import matplotlib.pyplot as plt
import numpy as np
import argparse
import lsne

# Get command line arguments
parser = argparse.ArgumentParser(description="Generate a normalized Allan Variance plot for a RO time serie or for COSO counter values.")
parser.add_argument("-t", dest="title", type=str, default="", help="plot title")
parser.add_argument("-q", "--quiet", action='store_true', help="quiet mode, only display the measured value")
parser.add_argument("datafile", type=str, help="data input file (text format, should contain one sample per line)")
parser.add_argument("plotfile", type=str, help="plot output file (possibles extensions png, jpg, pdf)")
args=parser.parse_args()

# Load the data file
data = np.loadtxt(args.datafile)

# Compute the cumulative sum and the average value
csum = np.cumsum(data)
mean = np.mean(data)

# Prepare a log space for csum size
nspace = np.logspace(0, int(np.log10(np.size(csum)))-1, 1000).astype(int)

# Comput Allan variance
allanvar = np.zeros(0)
for n in nspace:
	allanvar = np.append(allanvar, np.var(np.diff(np.diff(csum[0:np.size(csum):n])))/mean**2)

# Do the polynomial regression LSNE (np.polyfit only fit values in high decades)
poly = lsne.regression(nspace, allanvar, [2, 1, 0])
if args.quiet:
	print("{:e};{:e};{:e}".format(poly[2], poly[1], poly[0]))
else:
	print("Polynomial regression coefficients:")
	print(" - quantif: {:e}".format(poly[2]))
	print(" - thermal: {:e}".format(poly[1]))
	print(" - flicker: {:e}".format(poly[0]))

# Plot in log/log
plt.title(args.title)
plt.xscale('log')
plt.yscale('log')
plt.xlabel('N (accumulation)')
plt.ylabel('Normalized variance')
plt.grid(visible=True, which='major', axis='both')
plt.plot(nspace, allanvar, marker='+')
plt.plot(nspace, np.polyval(poly, nspace), color='red')
plt.legend(['Variance','Polynomial fit'])
plt.savefig(args.plotfile)
