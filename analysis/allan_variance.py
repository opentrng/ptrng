import matplotlib.pyplot as plt
import numpy as np
import lsne
import sys

# Test command line arguments
if len(sys.argv)!=3:
	print("Usage: python {:s} <data> <plot>".format(sys.argv[0]))
	print("Generate a normalized Allan Variance <plot> for a ring oscillator. The <data> input file should contain one sample per period value at each line. Available plot file extensions are (png, jpg, pdf, svg).")
	quit()

# Get parameters
datafile = sys.argv[1]
plotfile = sys.argv[2]

# Load the ringo file
periods = np.loadtxt(datafile)

# Compute the absolute times and the average period
ti = np.cumsum(periods)
avg = np.mean(periods)

# Prepare a log space for ti size
nspace = np.logspace(0, int(np.log10(np.size(ti)))-1, 1000).astype(int)

# Comput Allan variance
allanvar = np.zeros(0)
for n in nspace:
	allanvar = np.append(allanvar, np.var(np.diff(np.diff(ti[0:np.size(ti):n])))/avg**2)

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
