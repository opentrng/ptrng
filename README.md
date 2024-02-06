# Introduction

Welcome to **OpenTRNG**! This project is dedicated to delivering the community open-source implementations of reference Physical True Random Number Generator (TRNG or PTRNG) based on ring oscillators. Through **OpenTRNG**, you have the ability to:

1. [Emulate noisy ring oscillators](emulator/#emulate-noisy-ring-oscillators)
2. [Emulate raw random number](emulator/#emulate-raw-random-numbers)
3. [Simulate](hardware/#simulate-hdl-sources), [compile](hardware/#compile-for-fpga) and [run](remote/) the PTRNG on FPGA
4. [Analyze and evaluate their outcomes](analysis/#analyze-and-evaluate-outputs)

**OpenTRNG** is fully compatible with [OpenTitan](https://opentitan.org), our PTRNG can be used as input for OpenTitan's hardware IP blocks. Please find more information in the [hardware section](hardware/#opentitan-compatibility).

> [!WARNING]
> The **OpenTRNG** project implements reference TRNG or PTRNG implementations as found in the scientific litterature, the source code is made available for accademic purposes only. As compliance with verification and certification standards cannot be guarantee, it shall not be deployed "as is" in a product. Please be aware that any misuse or unintended application of this project is beyond the responsibility of CEA. If you plan to integrate a Random Number Generator (RNG) into a product, feel free to contact us.

# Why OpenTRNG?

The objective of **OpenTRNG** is to offer reference architectures of ring-oscillator based True Random Number Generators (TRNG), also known as PTRNG, to the community. With the advancement of certification standards like [BSI AIS20/31](https://www.bsi.bund.de/dok/randomnumbergenerators) (used in the Common Criteria) and [NIST SP 800-90B](https://csrc.nist.gov/pubs/sp/800/90/b/final), the stochastic model of the entropy source is increasingly crucial in relation to validating statistical tests on output data. Here, we publish straightforward yet effective entropy sources for PTRNG to facilitate the validation of their stochastic models across various FPGA and ASIC targets.

## Available architectures

In RO-based True Random Number Generators (TRNGs), the RO serves as the entropy source. Specifically, the inherent jitter between two (or more) ROs generates relative phase noise, which is known random, uncontrollable, and unpredictable. This relative phase noise is then converted into random bits through a sampling mechanism.

As of now, **OpenTRNG** includes the following reference sampling architectures:

* Elementary based Ring Oscilator (ERO),
* Multi Ring Oscilator (MURO),
* Coherent Sampling Ring Oscilator (COSO).

# Quick-start

Take a look at repository organization and, based on your requirements, navigate to the relevant subdirectory to begin using **OpenTRNG**.

## Repository organization

The repository structure contains these main directories:

* `analysis`: contains the tools for the [analysis](analysis/#analyze-and-evaluate-outputs) of the resulting random binary sequences (such as entropy estimators and auto-correlations),
* `emulator`: includes the [ring oscillator time series emulator](emulator/#emulate-noisy-ring-oscillators) and the [raw random number emulators](emulator/#emulate-raw-random-numbers),
* `hardware`: encloses HDL sources for [simulation](hardware/#simulate-hdl-sources) and [FPGA implementation](hardware/#compile-for-fpga) of the PTRNG,
* `remote`: include scripts for remote control the **OpenTRNG** FPGA target from a PC.

## Prerequisites

### Python

Create a virtual environment `$ python3 -m venv .venv` activate the venv `$ .ven/bin/activate` and install required packages with `$ pip install -r requirements.txt`. For other Python environment or package managers (like `conda`), all required modules are listed in `requirements.txt`.

### HDL simulator

You can perform VHDL simulation for **OpenTRNG** blocks using [GHDL](https://github.com/ghdl/ghdl) or other various simulators such as QuestaSim. Ensure that the `ghdl` command (or other simulator command) is accessible in your path. Testbenches for simulation and verification are written in python with [cocotb](https://www.cocotb.org). The generated waves (`vcd` files) can be displayed with [GTKWave](https://sourceforge.net/projects/gtkwave).

If you are not using `ghdl`, please refer to the `hardware/sim/config.mk` file to configure your own simulator for all the testbenches.

# License and contributions

The **OpenTRNG** project is distributed under the GNU GPLv3 license.

Pull requests are welcome and will be reviewed before being merged. No integration timelines are promised. The code is maintained by [CEA](https://www.cea.fr/english)-[Leti](https://www.leti-cea.com/cea-tech/leti/english/Pages/Applied-Research/Facilities/cyber-security-platform.aspx).
