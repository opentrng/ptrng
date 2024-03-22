import regmap as OpenTRNG
import fluart as Fluart
import time
import argparse

# Get command line arguments
parser = argparse.ArgumentParser(description="Reads data from the RNG FIFO")
parser.add_argument("-div", required=False, type=int, default=1, help="frequency divider (applies on RO0)")
parser.add_argument("-count", required=False, type=int, default=-1, help="number of data to read")
args=parser.parse_args()

# Open the UART to the register map
interface = Fluart.CmdProc()
reg = OpenTRNG.RegMap(interface)

# Reset and check the board
reg.control_bf.reset = 1
interface.check(reg.id_bf.uid, reg.id_bf.rev)

# Set the frequency divider
reg.freqdivider_bf.value = args.div

# Enable RO0 and RO1
reg.ring_bf.en = 0x3

# Read words
read = 0
while read<args.count or args.count==-1:
	while reg.fifoctrl_bf.empty == 1:
		time.sleep(0.01)
	print("{:d}".format(reg.fifodata_bf.data))
	if reg.fifoctrl_bf.full == 1:
		print("WARNING: the FIFO has been full, data may have been loosed!")
	read += 1

# Disable all the ROs
reg.ring_bf.enable = 0x00000000
