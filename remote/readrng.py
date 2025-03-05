import regmap as OpenTRNG
import fluart as Fluart
import time
import argparse

# Get command line arguments
parser = argparse.ArgumentParser(description="Reads data from the RNG FIFO")
parser.add_argument("-d", dest="div", required=False, type=int, default=1, help="frequency divider (applies on RO0 for ERO and COSO)")
parser.add_argument("-c", dest="count", required=False, type=int, default=-1, help="number of data to read (-1 is infinite, default)")
parser.add_argument("-m", dest="mode", required=True, type=str, choices=['lsb', 'bits', 'word'], help="read mode for FIFO data")
parser.add_argument("-s", "--single", action='store_true', default=False, help="do not read data in burst mode")
parser.add_argument("file", type=str, help="output data file (text)")
args=parser.parse_args()

# Open the output file
file = open(args.file, "wt")

# Open and check the UART to the register map
interface = Fluart.CmdProc()
reg = OpenTRNG.RegMap(interface)
interface.check(reg.id_bf.uid, reg.id_bf.rev)

# Disable the ROs
reg.ring_bf.en = 0x00000000

# Reset the PTRNG
reg.control_bf.reset = 1

# Set the frequency divider
reg.freqdivider_bf.value = args.div

# No conditioning (we read RRN)
reg.control_bf.conditioning = 0

# Disable the bit packer for 'lsb' and 'word' mode
if args.mode == 'lsb' or args.mode == 'word':
	reg.fifoctrl_bf.nopacking = 1
else:
	reg.fifoctrl_bf.nopacking = 0

# Set default read burst size
if not args.single:
	burstsize = reg.fifoctrl_bf.burstsize
	print("Burst size: {:d} words (32bit)".format(burstsize))

# Clear the FIFO and enable all ring oscillators
reg.fifoctrl_bf.clear = 1
reg.ring_bf.en = 0xFFFFFFFF

# Read words
count = 0
while count < args.count or args.count == -1:
	if args.single:
		while reg.fifoctrl_bf.empty == 1:
			time.sleep(0.01)
		bytes = int(reg.fifodata_bf.data).to_bytes(4, 'big')
	else:
		while reg.fifoctrl_bf.rdburstavailable == 0:
			time.sleep(0.01)
		bytes = interface.burstread(reg.FIFODATA_ADDR, burstsize)
	words = [int.from_bytes(bytes[i:i+4], 'big') for i in range(0, len(bytes), 4)]
	for word in words:
		if args.mode == 'bits':
			for i in range(0, 32):
				file.write("{:d}\n".format(0x01 & word>>i))
				count += 1
				if count>=args.count and args.count>0:
					break
		elif args.mode == 'lsb':
			file.write("{:d}\n".format(0x01 & word))
			count += 1
		else:
			file.write("{:d}\n".format(word))
			count += 1
	if reg.fifoctrl_bf.full == 1:
		print("WARNING: FIFO full, data are not contiguous!")

# Disable all ring oscillators
reg.ring_bf.en = 0x00000000
