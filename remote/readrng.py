import regmap as OpenTRNG
import fluart as Fluart
import time
import argparse

# Get command line arguments
parser = argparse.ArgumentParser(description="Reads data from the RNG FIFO")
parser.add_argument("-div", required=False, type=int, default=1, help="frequency divider (applies on RO0 for ERO and COSO)")
parser.add_argument("-count", required=False, type=int, default=-1, help="number of data to read (-1 is infinite, default)")
parser.add_argument("-mode", required=True, type=str, choices=['lsb', 'bits', 'word'], help="read mode for FIFO data")
parser.add_argument("file", type=str, help="output data file (text)")
args=parser.parse_args()

# Open the output file
file = open(args.file, "wt")

# Open the UART to the register map
interface = Fluart.CmdProc()
reg = OpenTRNG.RegMap(interface)

# Reset and check the board
reg.control_bf.reset = 1
interface.check(reg.id_bf.uid, reg.id_bf.rev)

# Set the frequency divider
reg.freqdivider_bf.value = args.div

# Disable the bit packer for 'lsb' and 'word' mode
if args.mode == 'lsb' or args.mode == 'word':
	reg.fifoctrl_bf.packbits == 0

# Enable RO0 and RO1
reg.ring_bf.en = 0x3

# Read words
read = 0
while read<args.count or args.count==-1:
	while reg.fifoctrl_bf.empty == 1:
		time.sleep(0.01)
	data = reg.fifodata_bf.data
	if args.mode == 'bits':
		for i in range(0, 32):
			file.write("{:d}\n".format(0x01 & data>>i))
			read += 1
			if read>=args.count and args.count>0:
				break
	elif args.mode == 'lsb':
		file.write("{:d}\n".format(0x01 & data))
		read += 1
	else:
		file.write("{:d}\n".format(data))
		read += 1
	if reg.fifoctrl_bf.full == 1:
		print("WARNING: FIFO full, data are not contiguous!")

# Disable all the ROs
reg.ring_bf.enable = 0x00000000
