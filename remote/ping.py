import regmap as OpenTRNG
import fluart as Fluart

# Open and check the UART to the register map
interface = Fluart.CmdProc()
reg = OpenTRNG.RegMap(interface)
interface.check(reg.id_bf.uid, reg.id_bf.rev)

# Success
print("OpenTRNG board connection is OK!")
