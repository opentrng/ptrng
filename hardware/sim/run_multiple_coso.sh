#!/bin/bash

# OpenTRNG base directory
opentrng=../..

# Numer of periods to generate
numperiods=1e6

# RO1 frequency
ro1=500e6

# All RO2 frequencies
frequencies=(500000000 500000001 500000010 500000100 500001000 500010000 500100000 500200000 500300000 500400000 500500000 500600000 500700000 500800000 500900000 501000000 502000000 503000000 504000000 505000000 506000000 507000000 508000000 509000000 510000000 520000000 530000000 540000000 550000000)

# For each RO2 frequency
for ro2 in ${frequencies[@]}
do
	echo "Generating RO1 ${ro1} MHz"
	python ${opentrng}/emulator/generate_ro.py ${numperiods} ${ro1} > ${opentrng}/data/ro1.txt

	echo "Generating RO2 ${ro2}MHz"
	python ${opentrng}/emulator/generate_ro.py ${numperiods} ${ro2} > ${opentrng}/data/ro2.txt

	echo "Running simulation"
	make run TESTBENCH=coso_tb DURATION=10ms

	echo "Copying result file"
	basename=coso_original_tb_periods=${numperiods}_ro1=${ro1}_ro2=${ro2}
	mv ${opentrng}/data/coso_tb.txt ${opentrng}/data/${basename}.txt

	echo "Generating distribution"
	python ${opentrng}/analysis/coso_distribution.py ${opentrng}/data/${basename}.txt ${opentrng}/data/${basename}.png
done
