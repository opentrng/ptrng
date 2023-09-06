# Introduction

Welcome to **OpenTRNG**! This project is dedicated to delivering the community open-source implementations of reference entropy sources based on ring oscillators. Through **OpenTRNG**, you have the capability to:

1. [Emulate noisy ring oscillators](#emulate-noisy-ring-oscillators)
2. [Simulate entropy source architectures](#simulate-entropy-source-architectures)
3. TODO Execute True Random Number Generators on FPGA
4. TODO Analyze and evaluate their outcomes

## Available reference entropy sources

As of now, **OpenTRNG** includes the following reference architectures:

* Elementary based Ring Oscilator (ERO),
* Multi Ring Oscilator (MURO),
* Coherent Sampling Ring Oscilator (COSO).

## Repository organization

The repository structure contains:

* the `emulator` directory, including the ring oscillator time series emulator,
* the `hardware` directory, containing VHDL for simulation and FPGA implementation,
* the `software` directory, emcompassing all scripts designed for remote control of the **OpenTRNG** plateform on FPGA and for the analysis of the resulting random binary sequences.

## Prerequisites

### Python

Create a virtual environment `$ python3 -m venv .venv` activate the venv `$ .ven/bin/activate` and install required packages `$ pip install numpy colorednoise`.

### HDL simulator

You can perform VHDL simulation for **OpenTRNG** using Mentor QuestaSim (Modelsim). Ensure that the `vsimk` command is accessible in your  path. We have plans to incorporate GHDL support in the upcoming updates.

# Emulate noisy ring oscillators

The emulator has the capability to produce time series data for ring oscillators, incorporating phase noise. Each consecutive value represents the absolute timing of the rising edge of the RO signal. The phase noise encompasses both thermal (white) and flicker noise (colored).

As instance, to produce 10,000,000 cycles of a ring oscillator operating at a frequency of 500MHz, execute the following command:

```
$ cd emulator
$ python generate_ro.py 500e6 10e6 > ro.txt
```

Here is an example of the generated file:

```
1999658 fs
1998880 fs
1983733 fs
2001320 fs
1995537 fs
2002511 fs
2003033 fs
2012407 fs
2012336 fs
...
2002883 fs
1999630 fs
```

Optionnaly, Allan variance coefficients a1, a2 and noise facors f1, f2 can be specified for thermal and flicker noises.

```
$ python generate_ro.py 500e6 10e6 2.81e-14 1.16e-10 2 0.135
```

# Simulate entropy source architectures

Prior to run HDL simulation, it is imperative to create ringo time series `ro1.txt` and `ro2.txt` with at least 10M cycles. These files are taken as input stimuli for entropy sources and should be located in the `emulator` directory. Detailed instruction can be found in the [previous section](#emulate-noisy-ring-oscillators).

As of now all available testbenches are:
* `ero_tb`
* TODO

A Makefile has been supplied to facilitate simulations, it can be accessed from the `hardware/sim` directory. This Makefile incorporates the following commands.

Compile all VHDL files for simulation:

```
make compile

```

To start the QuestaSim GUI, initiate the simulation for the `ero_tb` testbench and load the waves:

```
make gui TESTBENCH=ero_tb

```

Alternatively, you can directly launch QuestaSim in batch mode and execute the simulation of the `ero_tb` testbench for a specified duration:

```
make run TESTBENCH=ero_tb DURATION=100us

```

In any case, simulator will save the binary streams from the entropy sources into the output files located at `hardware/sim/*.txt`.

If you make modifications to the VHDL sources, you have the option to compile them directly from the QuestaSim transcript command line using the `> do compile.tcl` command.

Important Note: For adequate phase noise accuracy in the ring oscillators, it is imperative to conduct VHDL simulation at a resolution of femtoseconds (fs).

# Howtos and receipes

## How to generate 10M bits with ERO

Assume we want to generate 1e7 bits with an ERO running at 500MHz and a division factor of 1000. Output rate will be at 500kbit/s, so we need 1e7 x 1000 = 1e10 periods of rings (ouch!).


```
cd emulator
python generate_ro.py 500e6 1e10 > ro1.txt
python generate_ro.py 500e6 1e10 > ro2.txt
```

Lets start for 20s of simulated time!

```
cd hardware/sim
make compile
make run TESTBENCH=ero_tb DURATION=20s
```

# Disclaimer

The **OpenTRNG** project is made available solely for educational purposes. It shall not be deployed "as is" in real-world applications, compliance with verification and certification standards is not guaranteed. Please be aware that any misuse or unintended application of this project is beyond the responsibility of CEA.


If you plan to integrate a True Random Number Generator (TRNG) into a product, you can hire our expertise. Feel free to reach us using the following links for further information.

* https://www.leti-cea.com/cea-tech/leti/english
* https://www.cea.fr/english

# License

The **OpenTRNG** project is distributed under the GNU GPLv3 license.
