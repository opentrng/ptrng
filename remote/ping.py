import regmap as OpenTRNG
import fluart as Fluart

# Open the UART to the register map
interface = Fluart.CmdProc()
reg = OpenTRNG.RegMap(interface)

# Reset and check the board
reg.control_bf.reset = 1
interface.check(reg.id_bf.uid, reg.id_bf.rev)

# Success
print("OpenTRNG board connection is OK!")
