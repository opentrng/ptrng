from jinja2 import Environment, FileSystemLoader
import argparse
import math

# Get command line arguments
parser = argparse.ArgumentParser(description="Generate configuration files for the digitalnoise entity. More specifically it generates: 'settings.vhd' that contains HDL constants, 'placeroute.*' that contains all timing/place/route constraints for digitalnoise (extension depending on vendor).")
parser.add_argument("-luts", required=True, type=int, help="number of LUT per slice")
parser.add_argument("-x", required=True, type=int, help="reserved area for placement (row of the first slice)")
parser.add_argument("-y", required=True, type=int, help="reserved area for placement (column of the first slice)")
parser.add_argument("-width", required=True, type=int, help="width of the reserved area for placement (in slice count)")
parser.add_argument("-height", required=True, type=int, help="height of the reserved area for placement (in slice count)")
parser.add_argument("-colwidth", type=int, required=True, help="column width (in slice count)")
parser.add_argument("-freqheight", type=int, required=True, help="height for the frequency counter block (in slice count)")
parser.add_argument("-digitheight", type=int, required=True, help="height for the digitizer block (in slice count)")
parser.add_argument("-hpad", type=int, required=True, help="horizontal padding between rows and colums (in slice count)")
parser.add_argument("-vpad", type=int, required=True, help="vertical padding between rows and colums (in slice count)")
parser.add_argument("-fmax", required=True, type=float, help="maximum estimated frequency for all ring-oscillators (Hz)")
parser.add_argument("-len", required=True, type=int, nargs='+', help="number of elements in each ring-oscillator")
args=parser.parse_args()

# Arguments post-processing
t = len(args.len)-1

# Command line argument summary
print("Reserved area for rings: (X{:d},Y{:d}) to (X{:d},Y{:d})".format(args.x, args.y, args.x+args.width-1, args.y+args.height-1))
print("LUTs per slice: {:d}".format(args.luts))
print("Padding between rows and colums: ({:d},{:d})".format(args.hpad, args.vpad))
print("Width for all blocks: {:d}".format(args.colwidth))
print("Height for blocks:")
print(" - frequency counters: {:d}".format(args.freqheight))
print(" - digitizer: {:d}".format(args.digitheight))
print("Number of ring-oscillators: {:d} (T={:d})".format(len(args.len), t))
print("Lengths of ROs: [{:s}]".format(', '.join(map("{:d}".format, args.len))))
print("Maximum estimated frequency: {:e} Hz".format(args.fmax))

# Add a reserved area for a frequency counter at given position (slice)
def add_freqcounter(x, y, width, height):
	freq = {}
	freq['name'] = "freq{:d}".format(index)
	freq['block'] = {}
	freq['block']['xilinx'] = xilinx_slice_area(x, y, width, height)
	print("- freqcounter_{:02d} origin=({:d},{:d}) size=({:d},{:d})".format(index, x, y, width, height))
	return freq

# Add a reserved area for the digitizer at given position (slice)
def add_digitizer(x, y, width, height):
	digit = {}
	digit['name'] = "sampler{:d}".format(index)
	digit['block'] = {}
	digit['block']['xilinx'] = xilinx_slice_area(x, y, width, height)
	print("- clkdivider_{:02d} origin=({:d},{:d}) size=({:d},{:d})".format(index, x, y, width, height))
	return digit

# Add a reserved area for a ring-oscillator at given position (slice)
def add_ring(x, y, width, index, length):
	height = math.ceil(length/(width*args.luts))
	half = math.ceil(length/height)
	print("- RO_{:02d} len={:d} half={:d} origin=({:d},{:d}) size=({:d},{:d})".format(index, length, half, x, y, width, height))
	for element in range(length):
		if 2*element <= length:
			i = 0
			j = element
			lut = j%args.luts
		else:
			i = 1
			j = length-1-element
		slice_i = i
		slice_j = int(j/args.luts)
		lut_i = j%args.luts
		print("  - element={:d} slice=({:d},{:d}) lut={:d}".format(element, x+slice_i, y+slice_j, lut_i))
	ring = {}
	ring['name'] = "ring{:d}".format(index)
	ring['len'] = length
	ring['fmax'] = args.fmax
	ring['block'] = {}
	ring['block']['xilinx'] = xilinx_slice_area(x, y, width, height)
	return ring, height

# Returns the string to locate a slice for Xilinx XDC syntax
def xilinx_slice(x, y):
	return "SLICE_X{:d}Y{:d}".format(x, y)

# Returns the string for an area of slices for Xilinx XDC syntax
def xilinx_slice_area(x, y, width, height):
	return "{:s}:{:s}".format(xilinx_slice(x, y), xilinx_slice(x+width-1, y+height-1))

# Start at the lower left corner of the reserved area
x = args.x
y = args.y
xstart = x
ystart = y
ymax = 0

# Prepare an empty dictionnary for the banks calculated parameters
banks = []

# For each RO
for index in range(len(args.len)):

	# Create a new dictionnary entry for the current bank
	bank = {}
	bank['index'] = index

	# Add the padding for isolation
	x += args.hpad
	y += args.vpad

	# Add the frequency counter
	bank['freq'] = add_freqcounter(x, y, args.colwidth, args.freqheight)
	y += args.freqheight

	# Add the digitizer
	# bank['digit'] = add_sampler(x, y, args.colwidth, args.splheight)
	# y += args.splheight

	# Add the RO
	bank['ring'], ringheight = add_ring(x, y, args.colwidth, index, args.len[index])
	y += ringheight
	x += args.colwidth

	# Check if it fits the reserved area
	assert x+args.hpad <= args.x+args.width, "Placement error for ring-oscillator {:d}, does not fit in the reserved width".format(index)
	assert y+args.vpad <= args.y+args.height, "Placement error for ring-oscillator {:d}, does not fit in the reserved height".format(index)
	ymax = max(y, ymax)

	# Check if the next RO will fit in the remaining width in the current row, or start a new row
	if x+args.hpad+2+args.hpad > args.x+args.width:
		x = xstart
		y = ymax
		ystart = ymax
		ymax = 0
	else:
		y = ystart

	# Append the bank to the dictionnary
	banks.append(bank)

print(banks)

# Init Jijna templating environement
environment = Environment(loader=FileSystemLoader("templates"))

# Generate the VHDL setting package
template = environment.get_template("settings.vhd.jinja")
content = template.render(
		banks = banks
	)
settings = open("settings.vhd", "w")
settings.write(content)
settings.close()

# Generate the Xilinx constraints file
template = environment.get_template("placeroute.xdc.jinja")
content = template.render(
		reserved = xilinx_slice_area(args.x, args.y, args.width, args.height),
		banks = banks
	)
settings = open("placeroute.xdc", "w")
settings.write(content)
settings.close()
