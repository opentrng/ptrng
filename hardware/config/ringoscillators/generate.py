import argparse

# Get command line arguments
parser = argparse.ArgumentParser(description="Generate the ring-oscillator configuration.")
parser.add_argument("type", type=str, choices=['ero', 'muro', 'coso'], help="type of the entropy source")
parser.add_argument("n1", type=float, nargs='+', help="first set of ring oscillators frequency in Hz")
parser.add_argument("n2", type=float, help="second ring oscillator frequency in Hz")
parser.add_argument("freq1", type=float, nargs='+', help="first set of ring oscillators frequency in Hz")
parser.add_argument("freq2", type=float, help="second ring oscillator frequency in Hz")
#parser.add_argument("div", type=int, help="divisor for the sampling clock (freq2)")
args=parser.parse_args()
