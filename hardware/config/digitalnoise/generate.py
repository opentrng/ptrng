from jinja2 import Environment, FileSystemLoader
import argparse
import math

# Get command line arguments
parser = argparse.ArgumentParser(description="Generate the digital noise source configuration files. More specifically it generates: a 'settings.vhd' file located in 'hardware/hdl' that contains HDL generic variables, ????")
parser.add_argument("-vendor", required=True, type=str, choices=['xilinx'], help="target vendor (for selecting the templates)")
parser.add_argument("-luts", required=True, type=int, help="number of LUT per slice")
parser.add_argument("-x", required=True, type=int, help="reserved area for rings placement, row of the first slice")
parser.add_argument("-y", required=True, type=int, help="reserved area for rings placement, column of the first slice")
parser.add_argument("-width", required=True, type=int, help="width of the reserved area for rings placement (in slice count)")
parser.add_argument("-height", required=True, type=int, help="height of the reserved area for rings placement (in slice count)")
parser.add_argument("-hpad", type=int, default=1, required=False, help="horizontal padding between ring-oscillators")
parser.add_argument("-vpad", type=int, default=1, required=False, help="vertical padding between ring-oscillators")
parser.add_argument("-len", required=True, type=int, nargs='+', help="number of elements in the ring-oscillator")
args=parser.parse_args()

# Arguments post-processing
t = len(args.len)-1

# Command line argument summary
print("Reserved area for rings: (X{:d},Y{:d}) to (X{:d},Y{:d})".format(args.x, args.y, args.x+args.width-1, args.y+args.height-1))
print("LUTs per slice: {:d}".format(args.luts))
print("Number of ring-oscillators: {:d} (T={:d})".format(len(args.len), t))
print("Lengths of ROs: [{:s}]".format(', '.join(map("{:d}".format, args.len))))

# Add a reserved area for a frequency counter at given position (slice)
def add_freqcounter(x, y):
	width = 2
	height = 1
	print("- freqcounter_{:02d} origin=({:d},{:d}) size=({:d},{:d})".format(index, x, y, width, height))
	return width, height

# Add a reserved area for the sampler at given position (slice)
def add_sampler(x, y):
	width = 2
	height = 1
	print("- clkdivider_{:02d} origin=({:d},{:d}) size=({:d},{:d})".format(index, x, y, width, height))
	return width, height

# Add a reserved area for a ring-oscillator at given position (slice)
def add_ring(x, y, index, length):
	width = 2
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
	return width, height #, dict

# Start at the lower left corner of the reserved area
x = args.x
y = args.y
xstart = x
ystart = y
ymax = 0

# For each RO
for index in range(len(args.len)):

	# Add the padding for isolation
	x += args.hpad
	y += args.vpad

	# Add the frequency counter
	width, height = add_freqcounter(x, y)
	y += height

	# Add the sampler
	width, height = add_sampler(x, y)
	y += height

	# Add the RO
	width, height = add_ring(x, y, index, args.len[index])
	y += height
	x += 2

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

# Init Jijna templating environement
environment = Environment(loader=FileSystemLoader("templates"))

# Generate the VHDL setting package
template = environment.get_template("settings.vhd.jinja")
content = template.render(
		t = t,
		ro_len = ', '.join(map("{:d}".format, args.len))
	)
settings = open("settings.vhd", "w")
settings.write(content)
settings.close()
