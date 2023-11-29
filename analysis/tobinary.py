import argparse

# Get command line arguments
parser = argparse.ArgumentParser(description="Converts a text file of integers to a binary packed file. The bit stream is constructed by taking the LSB from each integer value. This script is useful to convert ERO, MURO and COSO output to a binary stream.")
parser.add_argument("text", type=str, help="text input file (should contain one integer per line)")
parser.add_argument("binary", type=str, help="binary output file")
args=parser.parse_args()

# Open both files
fin = open(args.text, 'rt')
fout = open(args.binary, 'wb')

# Prepare counters
bitcount = 0
bytecount = 0
byte = 0 #b'x\00'

# Read each line until the EOF and pack bits to bytes
while True:
	line = fin.readline()
	if not line:
		break
	byte = (0xFF & (byte << 1)) | (0x01 & int(line[0]))
	if bitcount%8 == 7:
		fout.write(byte.to_bytes(1, 'big'))
		bytecount += 1
	bitcount += 1

# Close both files
fin.close()
fout.close()

# Display counters
print("{:d} bits read from {:s}".format(bitcount, args.text))
print("{:d} bytes written to {:s}".format(bytecount, args.binary))
