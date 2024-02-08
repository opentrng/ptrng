import argparse
import math

# Get command line arguments
parser = argparse.ArgumentParser(description="Generate the ring-oscillator configuration. ?????????????")
parser.add_argument("-lut", required=True, type=int, help="number of LUT per slice")
parser.add_argument("-x", required=True, type=int, help="rings placement zone, row of the first slice")
parser.add_argument("-y", required=True, type=int, help="rings placement zone, column of the first slice")
parser.add_argument("-width", required=True, type=int, help="rings placement zone width (in slice count)")
parser.add_argument("-height", required=True, type=int, help="rings placement zone height (in slice count)")
parser.add_argument("-hpad", type=int, default=1, required=False, help="horizontal padding between ring-oscillators")
parser.add_argument("-vpad", type=int, default=1, required=False, help="vertical padding between ring-oscillators")
parser.add_argument("-len", type=int, nargs='+', help="number of elements in the ring-oscillator")
args=parser.parse_args()

# Command line argument summary
print("Selected slices for ring: (X{:d},Y{:d}) to (X{:d},Y{:d})".format(args.x, args.y, args.x+args.width-1, args.y+args.height-1))
print("LUTs per slice: {:d}".format(args.lut))
print("Number of ring-oscillators: {:d} (T={:d})".format(len(args.len), len(args.len)-1))
print("Lengths of ROs: [{:s}]".format(', '.join(map("{:d}".format, args.len))))

# Slice iterator
ro_index = 0
ro_len = args.len[ro_index]
ro_width = 2
ro_height = math.ceil(ro_len/(ro_width*args.lut))
ro_half = math.ceil(ro_len/ro_width)
ro_x = 0
ro_y = 0
print("- RO_{:02d} len={:d} half={:d} x={:d} y={:d} width={:d} height={:d}".format(ro_index, ro_len, ro_half, ro_x, ro_y, ro_width, ro_height))
for element in range(ro_len):
	if element < ro_half:
		i = 0
		j = element
		lut = j%args.lut
	else:
		i = 1
		j = ro_len-1-element
	slice_i = i
	slice_j = int(j/args.lut)
	lut_i = j%args.lut
	slice_xy = "X{:d}Y{:d}".format(ro_x+slice_i, ro_y+slice_j)
	print("  - element={:d} slice={:s} lut={:d}".format(element, slice_xy, lut_i))
	