# Introduction

Welcome to **OpenTRNG**! This project is dedicated to delivering the community open-source implementations of reference entropy sources based on ring oscillators. Through **OpenTRNG**, you have the capability to:

1. [Emulate noisy ring oscillators](#emulate-noisy-ring-oscillators)
2. [Simulate entropy source architectures](#simulate-entropy-source-architectures)
3. [Run entropy sources on FPGA](#run-entropy-sources-on-fpga)
4. [Analyze and evaluate their outcomes](#analyze-and-evaluate-outputs)

## Disclaimer

The **OpenTRNG** project implements reference implementations for entropy sources and TRNG as found in the scientific litterature, the source code is made available for accademic purposes only. As compliance with verification and certification standards cannot be guarantee, it shall not be deployed "as is" in a product. Please be aware that any misuse or unintended application of this project is beyond the responsibility of CEA.

If you plan to integrate a True Random Number Generator (TRNG) into a product, feel free to contact us using the following links for further information: [CEA](https://www.cea.fr/english)-[Leti](https://www.leti-cea.com/cea-tech/leti/english/Pages/Applied-Research/Facilities/cyber-security-platform.aspx)

## Available entropy sources

As of now, **OpenTRNG** includes the following reference architectures:

* Elementary based Ring Oscilator (ERO),
* Multi Ring Oscilator (MURO),
* Coherent Sampling Ring Oscilator (COSO).

## Repository organization

The repository structure contains:

* the `emulator` directory, including the ring oscillator time series emulator,
* the `hardware` directory, containing VHDL for simulation and FPGA implementation,
* the `software` directory, emcompassing all scripts designed for remote control of the **OpenTRNG** plateform on FPGA and for the analysis of the resulting random binary sequences,
* the `data` directory, used to store all generated and measured data.

## Prerequisites

### Python

Create a virtual environment `$ python3 -m venv .venv` activate the venv `$ .ven/bin/activate` and install required packages `$ pip install -r requirements.txt`.

### HDL simulator

You can perform VHDL simulation for **OpenTRNG** using Mentor QuestaSim (Modelsim). Ensure that the `vsimk` command is accessible in your  path. We have plans to incorporate GHDL support in the upcoming updates.

# Emulate noisy ring oscillators

The emulator has the capability to produce time series data for ring oscillators (RO), incorporating phase noise. Each consecutive value represents the absolute timing of the rising edge of the RO signal. The phase noise encompasses both thermal (white) and flicker noise (colored).

As instance, to produce 10,000,000 cycles of a ring oscillator operating at a frequency of 500MHz, execute the following command:

```
$ python emulator/timeseries.py 10e6 500e6 data/ro.txt
```

Here is an example of the generated file, each line represents a RO period in femtosecond (fs):

```
1999658
1998880
1983733
2001320
1995537
2002511
2003033
2012407
2012336
...
2002883
1999630
```

Optionnaly, Allan variance coefficients a1, a2 and noise facors f1, f2 can be specified for both thermal and flicker noises.

```
$ python emulator/generate_ro.py -a1 2.56e-14 -f1 1.919 -a2 1.11e-09 -f2 0.139 10e6 500e6 data/ro.txt
```

# Simulate entropy source architectures

Prior to run HDL simulation, it is imperative to create ringo time series `ro1.txt` and `ro2.txt` with at least 10M cycles each. These files are taken as input stimuli for entropy sources and should be located in the `data` directory. Detailed instruction can be found in the [previous section](#emulate-noisy-ring-oscillators).

As of now all available testbenches are:
* `ero_tb`
* `coso_tb`
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
make run TESTBENCH=ero_tb DURATION=10ms

```

In any case, simulator will save the binary streams from the entropy sources into the output text files `data/*_tb.txt`. These text files can be converted to binary files with the script `convert_to_binary.py` located in the `analysis` directory.

If you make modifications to the VHDL sources, you have the option to compile them directly from the QuestaSim transcript command line using the `> do compile.tcl` command.

Important Note: For adequate phase noise accuracy in the ring oscillators, it is imperative to conduct VHDL simulation at a resolution of femtoseconds (fs).

# Run entropy sources on FPGA

# Analyze and evaluate outputs

All analyze and evaluation tools are available in the `analyze` directory.

## Allan variance

You can compute the Allan Variance using data for a ring oscillator time serie, whether it's obtained from measurements or emulation. The Python script `allanvariance.py` can plot the normalized Allan Variance versus samples accumulation. For instance, you can use the following command to plot the Allan Variance of an emulated ring oscillator:

```
$ python analysis/allan_variance.py -t "Plot title" data/ro1.txt data/allanvar.png
```

![Allan variance example for a 500Mz ring oscillator](images/allanvariance.png)

Please note that the Allan variance can also be plotted for the COSO counter values.

## COSO counter distribution

You can visualize the counter values generated by the Coherent Sampling Ring Oscillator (COSO), whether simulated or obtained from the FPGA board, by creating a histogram using the Python script `distribution.py`.

```
$ python analysis/distribution.py -t "Plot title" data/coso_tb.txt data/distribution.png
```

![COSO values with RO pair at 500MHz and 505MHz](images/cosodistribution.png)

The provided example illustrates the generation of a COSO distribution plot using data from `coso_tb.txt`, which is produced through simulation.

## Entropy estimation

Entropy estimators take binary files as input. The script `tobinary.py` can be used to convert ERO, MURO and COSO text output files to binary. This script takes one integer value (0, 1, or n) per line, extracts the less significant bit (LSB) and pack successive bits to bytes.

You can estimate entropy of the generated binary streams with the script `entropy.py` and different estimators:
* Shannon entropy ([Wikipedia](https://en.wikipedia.org/wiki/Entropy_(information_theory)))
* Most Common Value (from [NIST SP800-90B](https://csrc.nist.gov/pubs/sp/800/90/b/final))
* Markov (from [NIST SP800-90B](https://csrc.nist.gov/pubs/sp/800/90/b/final))
* T8 from [BSI AIS 20/31](https://www.bsi.bund.de/dok/randomnumbergenerators) test procedure B

Estimators can be computed for different samples size from 1 to 32 bits.

```
$ python analysis/entropy.py data/ero_tb.bin mcv -b 8
```

The provided example computes the MCV estimator on 8 bits samples read from the `ero_tb.bin` binary file.

# Howtos and receipes

## How to generate 10M bits with ERO

Assume we want to generate 1e7 raw random bits with an ERO running at 500MHz and a division factor of 1000. Output rate will be at 500kbit/s, we need 1e7 x 1000 = 1e10 periods of rings (80GB for each RO file, ouch!).


```
python emulator/generate_ro.py 1e10 500e6 > data/ro1.txt
python emulator/generate_ro.py 1e10 500e6 > data/ro2.txt
```

Lets start for 20s of simulated time (takes several CPU hours depending its performance)!

```
cd hardware/sim
make compile
make run TESTBENCH=ero_tb DURATION=20s
```

Please note that for long time series, the emulator requires a significant amount of RAM. In such cases, it is advisable to split the generation process into smaller segments and concatenate them.

## How to run standardized test

# License

The **OpenTRNG** project is distributed under the GNU GPLv3 license.

# Contributions

Pull requests are welcome and will be reviewed before being merged. No timelines are promised. The code is maintained by [CEA](https://www.cea.fr/english)-[Leti](https://www.leti-cea.com/cea-tech/leti/english/Pages/Applied-Research/Facilities/cyber-security-platform.aspx)
