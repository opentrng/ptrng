import matplotlib.pyplot as plt
import numpy as np
import argparse

# Get command line arguments
parser = argparse.ArgumentParser(description="Generate a log distribution plot for COSO counter values.")
parser.add_argument("-t", dest="title", type=str, required=False, default="", help="plot title")
parser.add_argument("-l", "--log", action='store_true', required=False, help="set log scale for vertical axis")
parser.add_argument("-b", dest="bins", type=int, required=False, default=100, help="plot title")
parser.add_argument("datafile", type=str, help="data input file (text format, should contain one counter value per line)")
parser.add_argument("plotfile", type=str, help="plot output file (possibles extensions png, jpg, pdf)")
args=parser.parse_args()

# Load the data
data = np.loadtxt(args.datafile)

# Plot the file
fig = plt.figure()
plt.title(args.title)
plt.xlabel('Values')
plt.ylabel('Count')
if args.log:
	plt.yscale('log')
plt.hist(data, bins=args.bins)
plt.savefig(args.plotfile)
