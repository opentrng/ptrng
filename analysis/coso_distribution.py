import matplotlib.pyplot as plt
import numpy as np
import sys

# Test command line arguments
if len(sys.argv)!=3 and len(sys.argv)!=4:
	print("Usage: python {:s} <data> <plot> [<title>]".format(sys.argv[0]))
	print("Generate a log distribution <plot> for COSO counters with <title>. The <data> input file should contain one counter value per line.")
	quit()

# Get parameters
datafile = sys.argv[1]
plotfile = sys.argv[2]
if len(sys.argv)==4:
	title = sys.argv[3]
else:
	title = ''

# Load the data
data = np.loadtxt(datafile)

# Plot the file
fig = plt.figure()
if title != '':
	plt.title(title)
plt.xlabel('Values')
plt.ylabel('Count')
plt.yscale('log')
plt.hist(data, bins=100)
plt.savefig(plotfile)
