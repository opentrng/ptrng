# Introduction

Welcome to **OpenTRNG/entropy**! This project is dedicated to delivering the community open-source implementations of reference entropy sources based on ring oscillators for a Physical True Random Number Generator (TRNG or PTRNG). Through **OpenTRNG/entropy**, you have the capability to:

1. [Emulate noisy ring oscillators](emulator/#emulate-noisy-ring-oscillators)
2. [Emulate entropy sources](emulator/#emulate-entropy-source)
3. [Simulate entropy source HDL](hardware/#simulate-entropy-source-hdl)
4. [Compile](hardware/#compile-entropy-sources-on-fpga) and [run](remote/) entropy sources on FPGA
5. [Analyze and evaluate their outcomes](analysis/#analyze-and-evaluate-outputs)

**OpenTRNG/entropy** is fully compatible with [OpenTitan](https://opentitan.org), our entropy source implementations can be used as PTRNG or CSRNG input for OpenTitan's hardware IP blocks.

> [!WARNING]
> The **OpenTRNG** project implements reference implementations for entropy sources and TRNG as found in the scientific litterature, the source code is made available for accademic purposes only. As compliance with verification and certification standards cannot be guarantee, it shall not be deployed "as is" in a product. Please be aware that any misuse or unintended application of this project is beyond the responsibility of CEA. If you plan to integrate a Random Number Generator (RNG) into a product, feel free to contact us.

# Why OpenTRNG?

_TODO_

## Available entropy sources

As of now, **OpenTRNG/entropy** includes the following reference architectures:

* Elementary based Ring Oscilator (ERO),
* Multi Ring Oscilator (MURO),
* Coherent Sampling Ring Oscilator (COSO).

# Quick-start

Take a look at repository organization and, based on your requirements, navigate to the relevant subdirectory to begin using **OpenTRNG**.

## Repository organization

The repository structure contains these main directories:

* `emulator`: includes the [ring oscillator time series emulator](emulator/#emulate-noisy-ring-oscillators) and [entropy sources emulator](emulator/#emulate-entropy-source),
* `hardware`: contains VHDL for [simulation](hardware/#simulate-entropy-source-hdl), [FPGA implementation](hardware/#compile-entropy-sources-on-fpga) and **OpenTRNG** plateform remote control from a PC,
* `analysis`: inclues the tools for the [analysis](analysis/#analyze-and-evaluate-outputs) of the resulting random binary sequences (such as entropy estimators and auto-correlations).

## Prerequisites

### Python

Create a virtual environment `$ python3 -m venv .venv` activate the venv `$ .ven/bin/activate` and install required packages with `$ pip install -r requirements.txt`. For other Python environment or package managers (like `conda`), all required modules are listed in `requirements.txt`.

### HDL simulator

You can perform VHDL simulation for **OpenTRNG** blocks using [GHDL](https://github.com/ghdl/ghdl) or other various simulators such as QuestaSim. Ensure that the `ghdl` command (or other simulator command) is accessible in your path. Testbenches for simulation and verification are written in python with [cocotb](https://www.cocotb.org). The generated waves (`vcd` files) can be displayed with [GTKWave](https://sourceforge.net/projects/gtkwave).

If you are not using `ghdl`, please refer to the `hardware/sim/config.mk` file to configure your own simulator for all the testbenches.

# License and contributions

The **OpenTRNG** project is distributed under the GNU GPLv3 license.

Pull requests are welcome and will be reviewed before being merged. No integration timelines are promised. The code is maintained by [CEA](https://www.cea.fr/english)-[Leti](https://www.leti-cea.com/cea-tech/leti/english/Pages/Applied-Research/Facilities/cyber-security-platform.aspx).
