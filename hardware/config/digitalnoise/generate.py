from jinja2 import Environment, FileSystemLoader
import argparse
import math
import sys

# Get command line arguments
parser = argparse.ArgumentParser(description="Generate configuration files for the digitalnoise entity. More specifically it generates: 'settings.vhd' that contains HDL constants and 'placeroute.*' that contains all timing/place/route constraints for digitalnoise (extension depending on vendor).")
parser.add_argument("-vendor", required=True, type=str, choices=['xilinx'], help="target vendor (for selecting the templates)")
parser.add_argument("-luts", required=True, type=int, help="number of LUT per item (per slice for Xilinx, per LE for Intel Altera)")
parser.add_argument("-fixedlutpin", required=False, type=str, default='', help="optional parameter to fix the input pin for all LUTs (the value is the name of the pin)")
parser.add_argument("-x", required=True, type=int, help="origin abscissa for the reserved area ")
parser.add_argument("-y", required=True, type=int, help="origin ordinate for the reserved area")
parser.add_argument("-maxwidth", required=True, type=int, help="maximum width for the reserved area")
parser.add_argument("-maxheight", required=True, type=int, help="maximum height for the reserved area")
parser.add_argument("-border", type=int, required=True, help="forbidden border all around inside the reserved area")
parser.add_argument("-ringwidth", type=int, required=True, help="column width for a ring-oscillator")
parser.add_argument("-digitheight", type=int, required=True, help="height for the digitizer block")
parser.add_argument("-hpad", type=int, required=True, help="horizontal padding between ROs")
parser.add_argument("-vpad", type=int, required=True, help="vertical padding between ROs")
parser.add_argument("-fmax", required=True, type=float, help="maximum estimated frequency for all ring-oscillators (Hz)")
parser.add_argument("-len", required=True, type=int, nargs='+', help="number of elements in each ring-oscillator")
args=parser.parse_args()

# Arguments post-processingc
cmd = "python "+" ".join(sys.argv)
t = len(args.len)-1

# Command line argument summary
print("LUTs per item: {:d}".format(args.luts))
print("Reserved area for rings: (X{:d},Y{:d}) to max (X{:d},Y{:d})".format(args.x, args.y, args.x+args.maxwidth-1, args.y+args.maxheight-1))
print("Forbidden border inside the reserved area: {:d}".format(args.border))
print("Padding between rows and colums: ({:d},{:d})".format(args.hpad, args.vpad))
print("Width for a ring-oscillator: {:d}".format(args.ringwidth))
print("Height for a digitizer: {:d}".format(args.digitheight))
print("Number of ring-oscillators: {:d} (T={:d})".format(len(args.len), t))
print("Lengths of ROs: [{:s}]".format(', '.join(map("{:d}".format, args.len))))
print("Maximum estimated frequency: {:e} Hz".format(args.fmax))

# Add a reserved area for a ring-oscillator at given position
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
		item_i = i
		item_j = int(j/args.luts)
		lut_i = j%args.luts

		# Create a dictionnary entry for the element
		xilinx_element = {}
		xilinx_element['slice'] = xilinx_slice(x+item_i, y+item_j)
		xilinx_element['lut'] = xilinx_lut(lut_i)
		if args.fixedlutpin:
			xilinx_element['fixedlutpin'] = args.fixedlutpin
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
		return "A6LUT"
	elif index==1:
		return "B6LUT"
	elif index==2:
		return "C6LUT"
	elif index==3:
		return "D6LUT"

# Prepare an empty dictionnary for the RO calculated parameters
rings = []

# Start ring-oscillator bank at the left corner just over the digitizer
bank_x = args.x + args.border
bank_y = args.y + args.border + args.digitheight

# For each RO
x = bank_x
y = bank_y
xmax = 0
ymax = 0
for index in range(len(args.len)):

	# Create a new dictionnary entry for the current ring
	ring = {}
	ring['index'] = index

	# Add the padding for isolation
	x += args.hpad
	y += args.vpad
	# if y > bank_y:
	# 	y += args.vpad

	# Add the ring-oscillator
	ring['parameters'], ringheight = add_ring(x, y, args.ringwidth, index, args.len[index])
	y += ringheight
	x += args.ringwidth

	# Check if it fits the reserved area
	assert x <= args.x+args.maxwidth-args.hpad-args.border, "Placement error for ring-oscillator {:d}, {:d} does not fit in the reserved width".format(index, x)
	assert y <= args.y+args.maxheight-args.vpad-args.border, "Placement error for ring-oscillator {:d}, {:d} does not fit in the reserved height".format(index, y)
	xmax = max(x, xmax)
	ymax = max(y, ymax)

	# Check if the next RO will fit in the remaining width in the current row, or start a new row
	if x+args.hpad+2+args.hpad > args.x+args.maxwidth:
		x = bank_x
		y = ymax
		if index < len(args.len)-1:
			ymax = 0
	else:
		y = bank_y

	# Append the bank to the dictionnary
	rings.append(ring)

# Set the final reserved area
final_width = xmax-args.x+args.hpad+args.border
final_height = ymax-args.y+args.vpad+args.border
digitalnoise = {}
digitalnoise['area'] = {}
digitalnoise['area']['xilinx'] = xilinx_slice_area(args.x, args.y, final_width, final_height)

# Set the ROs bank area
bank_width = final_width - 2*args.border
bank_height =  final_height - args.digitheight - 2*args.border
bank = {}
bank['area'] = {}
bank['area']['xilinx'] = xilinx_slice_area(bank_x, bank_y, bank_width, bank_height)
print("- bank origin=({:d},{:d}) size=({:d},{:d})".format(bank_x, bank_y, bank_width, bank_height))

# Set the digitizer area
digit_x = args.x + args.border
digit_y = args.y + args.border
digit_width = final_width - 2*args.border
digit_height =  args.digitheight
digitizer = {}
digitizer['area'] = {}
digitizer['area']['xilinx'] = xilinx_slice_area(digit_x, digit_y, digit_width, digit_height)
print("- digitizer origin=({:d},{:d}) size=({:d},{:d})".format(digit_x, digit_y, digit_width, digit_height))

# Init Jijna templating environement
environment = Environment(loader=FileSystemLoader("templates"))

# Generate the VHDL setting package
template = environment.get_template("settings.vhd.jinja")
content = template.render(
		cmd = cmd,
		rings = rings
	)
settings = open("settings.vhd", "w")
settings.write(content)
settings.close()

# Generate the Xilinx constraints file
template = environment.get_template("constraints.xdc.jinja")
content = template.render(
		cmd = cmd,
		digitalnoise = digitalnoise,
		digitizer = digitizer,
		bank = bank,
		rings = rings
	)
settings = open("constraints.xdc", "w")
settings.write(content)
settings.close()
