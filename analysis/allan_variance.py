import matplotlib.pyplot as plt
import numpy as np
import lsne
import sys

# Test command line arguments
if len(sys.argv)!=3:
	print("Usage: python {:s} <data> <plot>".format(sys.argv[0]))
	print("Generate a normalized Allan Variance <plot> for a ring oscillator time serie or for COSO counter values. The <data> input file should contain one sample per line.")
	quit()

# Get parameters
datafile = sys.argv[1]
plotfile = sys.argv[2]

# Load the data file
data = np.loadtxt(datafile)

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
print('Polynomial coefficients:')
print(poly)

# Plot in log/log
plt.title('Allan variance')
plt.xscale('log')
plt.yscale('log')
plt.xlabel('N accumulation')
plt.ylabel('Normalized variance')
plt.grid(visible=True, which='major', axis='both')
plt.plot(nspace, allanvar, marker='+')
plt.plot(nspace, np.polyval(poly, nspace), color='red')
plt.legend(['Variance','Polynomial fit'])
plt.savefig(plotfile)
