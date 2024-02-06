import serial

# Try to load user settings or fallback to defaults
try:
	import settings
	tty = settings.tty
except:
	tty = '/dev/ttyUSB1'

# Define the UART interface for read and write operations
class CmdProc:
	def __init__(self):
		self.port = serial.Serial(tty, timeout=5)
		self.port.baudrate = 115200

	def read(self, address):
		cmd = bytearray()
		cmd.append(0x00)
		cmd += address.to_bytes(2, 'big')
		self.port.write(cmd)
		return int.from_bytes(self.port.read(4), 'big')

	def write(self, address, value):
		cmd = bytearray()
		cmd.append(0x01)
		cmd += address.to_bytes(2, 'big')
		cmd += value.to_bytes(4, 'big')
		self.port.write(cmd)

	def check(self, uid, rev):
		assert uid==0xCEA3, "This is not an OpenTRNG target board"
		assert rev==1, "Wrong version of OpenTRNG target board"
