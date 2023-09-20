import sys

# Test command line arguments
if len(sys.argv)!=3:
	print("Usage: python {:s} <text> <binary>".format(sys.argv[0]))
	print("Converts a <text> file representing bits (one bit per line) to a <binary> packed file.")
	quit()

# Parameters
text = sys.argv[1]
binary = sys.argv[2]

# Open both files
fin = open(text, 'rt')
fout = open(binary, 'wb')

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
print("{:d} bits read from {:s}".format(bitcount, text))
print("{:d} bytes written to {:s}".format(bytecount, binary))
