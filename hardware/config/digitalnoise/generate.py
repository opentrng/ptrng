from jinja2 import Environment, FileSystemLoader
import argparse
import math
import sys

# Get command line arguments
parser = argparse.ArgumentParser(description="Generate configuration files for the digitalnoise entity. More specifically it generates: 'settings.vhd' that contains HDL constants, 'placeroute.*' that contains all timing/place/route constraints for digitalnoise (extension depending on vendor).")
parser.add_argument("-luts", required=True, type=int, help="number of LUT per slice")
parser.add_argument("-x", required=True, type=int, help="start row for the reserved area ")
parser.add_argument("-y", required=True, type=int, help="start comlumn for the reserved area")
parser.add_argument("-width", required=True, type=int, help="width of the reserved area")
parser.add_argument("-height", required=True, type=int, help="height of the reserved area")
parser.add_argument("-border", type=int, required=True, help="border width inside the reserved area before DMZ")
parser.add_argument("-ringwidth", type=int, required=True, help="column width for a ring-oscillator")
parser.add_argument("-digitheight", type=int, required=True, help="height for the digitizer block")
parser.add_argument("-hpad", type=int, required=True, help="horizontal padding between rows and colums")
parser.add_argument("-vpad", type=int, required=True, help="vertical padding between rows and colums")
parser.add_argument("-fmax", required=True, type=float, help="maximum estimated frequency for all ring-oscillators (Hz)")
parser.add_argument("-len", required=True, type=int, nargs='+', help="number of elements in each ring-oscillator")
args=parser.parse_args()

# Arguments post-processingc
cmd = "python "+" ".join(sys.argv)
t = len(args.len)-1

# Command line argument summary
print("LUTs per slice: {:d}".format(args.luts))
print("Reserved area for rings: (X{:d},Y{:d}) to (X{:d},Y{:d})".format(args.x, args.y, args.x+args.width-1, args.y+args.height-1))
print("Border inside the reserved area before DMZ: {:d}".format(args.border))
print("Padding between rows and colums: ({:d},{:d})".format(args.hpad, args.vpad))
print("Width for a ring-oscillator: {:d}".format(args.ringwidth))
print("Height for a digitizer: {:d}".format(args.digitheight))
print("Number of ring-oscillators: {:d} (T={:d})".format(len(args.len), t))
print("Lengths of ROs: [{:s}]".format(', '.join(map("{:d}".format, args.len))))
print("Maximum estimated frequency: {:e} Hz".format(args.fmax))

# Add a reserved area for the digitizer at given position (slice)
def add_digitizer(x, y, width, height):
	# Print base info
	print("- clkdivider_{:02d} origin=({:d},{:d}) size=({:d},{:d})".format(index, x, y, width, height))

	# Return a dictionnary entry for the name and area
	digit = {}
	digit['name'] = "sampler{:d}".format(index)
	digit['area'] = {}
	digit['area']['xilinx'] = xilinx_slice_area(x, y, width, height)
	return digit

# Add a reserved area for a ring-oscillator at given position (slice)
def add_ring(x, y, width, index, length):
	# Calculate base properties
	count = length+1 # (+1 for the monitoring 'and' gate)
	height = math.ceil(count/(width*args.luts))
	half = math.ceil(count/height)
	print("- RO_{:02d} length={:d} elements={:d} half={:d} origin=({:d},{:d}) size=({:d},{:d})".format(index, length, count, half, x, y, width, height))

	# Create the base dictionnary entry with name, len and fax
	ring = {}
	ring['name'] = "ring{:d}".format(index)
	ring['length'] = length
	ring['fmax'] = args.fmax

	# Create the elements entries
	ring['elements'] = {}
	ring['elements']['xilinx'] = []

	# Iterate for all elements 
	for element in range(count):
		# Increment i, j indexes by rows then columns
		if 2*element < count:
			i = 0
			j = element
			lut = j%args.luts
		else:
			i = 1
			j = count-1-element
		slice_i = i
		slice_j = int(j/args.luts)
		lut_i = j%args.luts

		# Create a dictionnary entry for the element
		entry = {}
		entry['slice'] = xilinx_slice(x+slice_i, y+slice_j)
		entry['lut'] = lut_i
		if element == 0:
			entry['name'] = "element_0_lut_nand"
		elif element == count-1:
			entry['name'] = "monitor_lut_and"
		else:
			entry['name'] = "element[{:d}].lut_buffer".format(element)
		ring['elements']['xilinx'].append(entry)
		print("  - element={:d} slice=({:d},{:d}) lut={:d}".format(element, x+slice_i, y+slice_j, lut_i))

	# Add a dictionnary entry for the area and return the whole dict
	ring['area'] = {}
	ring['area']['xilinx'] = xilinx_slice_area(x, y, width, height)
	return ring, height

# Returns the string to locate a slice for Xilinx XDC syntax
def xilinx_slice(x, y):
	return "SLICE_X{:d}Y{:d}".format(x, y)

# Returns the string for an area of slices for Xilinx XDC syntax
def xilinx_slice_area(x, y, width, height):
	return "{:s}:{:s}".format(xilinx_slice(x, y), xilinx_slice(x+width-1, y+height-1))

# Define the DMZ (reserved area minus the border)
dmz = {}
dmz['area'] = {}
dmz['area']['xilinx'] = xilinx_slice_area(args.x+args.border, args.y+args.border, args.width-2*args.border, args.height-2*args.border)

# Start first bank at the left corner of the reserved area, just after the border
x = args.x + args.border
y = args.y + args.border
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

	# Add the digitizer
	bank['digit'] = add_digitizer(x, y, args.ringwidth, args.digitheight)
	y += args.digitheight

	# Add the ring-oscillator
	bank['ring'], ringheight = add_ring(x, y, args.ringwidth, index, args.len[index])
	y += ringheight
	x += args.ringwidth

	# Check if it fits the reserved area
	assert x <= args.x+args.width-args.hpad-args.border, "Placement error for ring-oscillator {:d}, {:d} does not fit in the reserved width".format(index, x)
	assert y <= args.y+args.height-args.vpad-args.border, "Placement error for ring-oscillator {:d}, {:d} does not fit in the reserved height".format(index, y)
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

# Init Jijna templating environement
environment = Environment(loader=FileSystemLoader("templates"))

# Generate the VHDL setting package
template = environment.get_template("settings.vhd.jinja")
content = template.render(
		cmd = cmd,
		banks = banks
	)
settings = open("settings.vhd", "w")
settings.write(content)
settings.close()

# Generate the Xilinx constraints file
template = environment.get_template("constraints.xdc.jinja")
content = template.render(
		cmd = cmd,
		reserved = xilinx_slice_area(args.x, args.y, args.width, args.height),
		dmz = dmz,
		banks = banks
	)
settings = open("constraints.xdc", "w")
settings.write(content)
settings.close()
