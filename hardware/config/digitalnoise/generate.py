from jinja2 import Environment, FileSystemLoader
import argparse
import math
import sys

# Get command line arguments
parser = argparse.ArgumentParser(description="Generate configuration files for the digitalnoise entity. More specifically it generates: 'settings.vhd' that contains HDL constants and 'constraints.*' that contains all timing/placement/route constraints for the digitalnoise block (file extension depends on target vendor).")
parser.add_argument("-vendor", required=True, type=str, choices=['xilinx'], help="target vendor (for selecting the templates)")
parser.add_argument("-luts", required=True, type=int, help="number of LUT per item (per slice for Xilinx, per LE for Intel Altera)")
parser.add_argument("-x", required=True, type=int, help="lower left corner (x) of the reserved area")
parser.add_argument("-y", required=True, type=int, help="lower left corner (y) of the reserved area")
parser.add_argument("-maxwidth", required=True, type=int, help="maximum width for the reserved area")
parser.add_argument("-maxheight", required=True, type=int, help="maximum height for the reserved area")
parser.add_argument("-border", type=int, required=True, help="border size outside the DMZ for the placement of CDC and frequency counter")
parser.add_argument("-ringwidth", type=int, required=True, help="column width for each ring-oscillator")
parser.add_argument("-digitheight", type=int, required=True, help="height for each digitizer block")
parser.add_argument("-hpad", type=int, required=True, help="horizontal padding between rows and colums")
parser.add_argument("-vpad", type=int, required=True, help="vertical padding between rows and colums")
parser.add_argument("-fmax", required=True, type=float, help="maximum estimated frequency for all ring-oscillators (Hz)")
parser.add_argument("-len", required=True, type=int, nargs='+', help="number of elements in each ring-oscillator")
args=parser.parse_args()

# Arguments post-processingc
cmd = "python "+" ".join(sys.argv)
t = len(args.len)-1

# Command line argument summary
print("Reserved area for the whole digitalnoise block:")
print(" - start ({:d},{:d}) to ({:d},{:d}) maximum".format(args.x, args.y, args.x+args.maxwidth-1, args.y+args.maxheight-1))
print(" - maximum size ({:d},{:d})".format(args.maxwidth, args.maxheight))
print("LUTs per item: {:d}".format(args.luts))
print("Border size outside the DMZ for CDC and frequency counter: {:d}".format(args.border))
print("Padding between rows and colums: ({:d},{:d})".format(args.hpad, args.vpad))
print("Column width for each ring-oscillator: {:d}".format(args.ringwidth))
print("Row height for each digitizer: {:d}".format(args.digitheight))
print("Number of ring-oscillators: {:d} (T={:d})".format(len(args.len), t))
print("Lengths of ROs: [{:s}]".format(', '.join(map("{:d}".format, args.len))))
print("Maximum estimated frequency: {:e} Hz".format(args.fmax))

# Add a reserved area for the digitizer at given position
def add_digit(x, y, width, height):
	# Print base info
	print("- [digit{:d}] origin=({:d},{:d}) size=({:d},{:d})".format(index, x, y, width, height))

	# Return a dictionnary entry for the name and area
	digit = {}
	digit['name'] = "digit{:d}".format(index)
	digit['area'] = {}
	digit['area']['xilinx'] = xilinx_slice_area(x, y, width, height)
	return digit

# Add a reserved area for a ring-oscillator at given position
def add_ring(x, y, width, index, length):
	# Calculate base properties
	count = length+1 # (+1 for the monitoring 'and' gate)
	height = math.ceil(count/(width*args.luts))
	half = math.ceil(count/height)
	print("- [ring{:d}] length={:d} elements={:d} half={:d} origin=({:d},{:d}) size=({:d},{:d})".format(index, length, count, half, x, y, width, height))

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
		item_i = i
		item_j = int(j/args.luts)
		lut_i = j%args.luts

		# Create a dictionnary entry for the element
		xilinx_element = {}
		xilinx_element['slice'] = xilinx_slice(x+item_i, y+item_j)
		xilinx_element['lut'] = xilinx_lut(lut_i)
		if element == 0:
			xilinx_element['name'] = "element_0_lut_nand"
		elif element == count-1:
			xilinx_element['name'] = "monitor_lut_and"
		else:
			xilinx_element['name'] = "element[{:d}].lut_buffer".format(element)
		ring['elements']['xilinx'].append(xilinx_element)
		print("  - element={:d} item=({:d},{:d}) lut={:d}".format(element, x+item_i, y+item_j, lut_i))

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

# Returns the name of the LUT based on its index
def xilinx_lut(index):
	assert index <= 3
	if index==0:
		return "A5LUT"
	elif index==1:
		return "B5LUT"
	elif index==2:
		return "C5LUT"
	elif index==3:
		return "D5LUT"

# Start first bank at the left corner of the DMZ area
x = args.x + args.border
y = args.y + args.border
xstart = x
ystart = y
xmax = 0
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
	bank['digit'] = add_digit(x, y, args.ringwidth, args.digitheight)
	y += args.digitheight

	# Add the ring-oscillator
	bank['ring'], ringheight = add_ring(x, y, args.ringwidth, index, args.len[index])
	y += ringheight
	x += args.ringwidth

	# Check if it fits the reserved area
	assert x <= args.x+args.maxwidth-args.hpad-args.border, "Placement error for ring-oscillator {:d}, {:d} does not fit in the reserved width".format(index, x)
	assert y <= args.y+args.maxheight-args.vpad-args.border, "Placement error for ring-oscillator {:d}, {:d} does not fit in the reserved height".format(index, y)
	xmax = max(x, xmax)
	ymax = max(y, ymax)

	# Check if the next RO will fit in the remaining width in the current row, or start a new row
	if x+args.hpad+2+args.hpad > args.x+args.maxwidth:
		x = xstart
		y = ymax
		ystart = ymax
		if index < len(args.len)-1:
			ymax = 0
	else:
		y = ystart

	# Append the bank to the dictionnary
	banks.append(bank)

# Set the final reserved area
final_width = xmax-args.x+args.hpad+args.border
final_height = ymax-args.y+args.vpad+args.border
reserved = xilinx_slice_area(args.x, args.y, final_width, final_height)

# Define the DMZ (equals to reserved area without the border)
dmz = {}
dmz['area'] = {}
dmz['area']['xilinx'] = xilinx_slice_area(args.x+args.border, args.y+args.border, final_width-2*args.border, final_height-2*args.border)

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
		reserved = reserved,
		dmz = dmz,
		banks = banks
	)
settings = open("constraints.xdc", "w")
settings.write(content)
settings.close()
