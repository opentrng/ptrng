#!/bin/bash

# Define PATHs and tools
OUT=/nobackup/fp208036/campaign_opentrng_april
OPENTRNG=../../../../..
ANALYSIS=${OPENTRNG}/analysis
HARDWARE=${OPENTRNG}/hardware
REMOTE=${OPENTRNG}/remote
TARGET="${HARDWARE}/target/fpga/xilinx/arty_a7_35t"
PROJECT="opentrng_arty_a7_35t"
GENERATE="python ${HARDWARE}/config/digitalnoise/generate.py"
VIVADO="vivado"
FREQUENCY="python ${REMOTE}/frequency.py"
READRNG="python ${REMOTE}/readrng.py"
DISTRIBUTION="python ${ANALYSIS}/distribution.py"
TOBINARY="python ${ANALYSIS}/tobinary.py"
ENTROPY="python ${ANALYSIS}/entropy.py"

# Define settings
DIGITIZERS=('ero' 'muro' 'coso')
TAKES=10
NUMFREQ=1000
NUMRAND=100000

# Create the output directory
rm -f "${OUT}/entropy.txt"
mkdir -p "${OUT}"

# Create the entropy file
echo "type;rings;div;take;mcv" > "${OUT}/entropy.txt"

# For ERO, COSO and MURO
for DIGITIZER in "${DIGITIZERS[@]}"
do
	# Define ring-oscillator LENGTHS depending on DIGITIZER type
	if [[ ${DIGITIZER} = 'muro' ]]
	then
		LENGTHS=('30,22,26,30,34,38' '20,16,18,20,22,24' '10,8,9,10,11,12')
	else
		LENGTHS=('40,40' '35,35' '30,30' '25,25' '22,22' '20,20' '18,18' '16,16' '14,14' '12,12' '10,10' '9,9' '8,8' '7,7' '6,6' '5,5' '4,4')
	fi

	# Define DIVIDERS depending on DIGITIZER type
	if [[ ${DIGITIZER} = 'coso' ]]
	then
		DIVIDERS=(1)
	else
		DIVIDERS=(10 20 30 50 70 100 200 300 500 700 1000 2000 3000 5000 7000 10000)
	fi

	# For all ring-oscillator LENGTHS
	for LENGTH in "${LENGTHS[@]}"
	do
		# For several TAKES
		for TAKE in $(seq 1 ${TAKES})
		do
			# Create an intermediate slug
			SLUG0="${DIGITIZER}_n${LENGTH}_take${TAKE}"
			echo "=== ${SLUG0} ========================================================="

			# Generate settings and constraints
			echo " - Generate HDL settings and constraints"
			${GENERATE} -args "${TARGET}/generate_${DIGITIZER}.args" -len `echo ${LENGTH} | sed 's/,/ /g'` > "${OUT}/${SLUG0}_generate.log"

			# Synthetise, implement, generate bitstream and program FPGA
			echo " - Compile and program FPGA"
			${VIVADO} -mode batch -source generate_bitstream.tcl "${TARGET}/${PROJECT}.xpr" > "${OUT}/${SLUG0}_vivado.log"
			cp "${TARGET}/${PROJECT}.runs/impl_1/target.bit" "${OUT}/${SLUG0}_target.bit" >> "${OUT}/${SLUG0}_vivado.log"
			${VIVADO} -mode batch -source program_bitstream.tcl -tclargs "${OUT}/${SLUG0}_target.bit" >> "${OUT}/${SLUG0}_vivado.log"

			# Get frequency values for each RO0/RO1 and plot the distribution
			for RING in $(seq 1 `echo ${LENGTH} | sed 's/,/ /g' | wc -w`)
			do
				INDEX=$((RING-1))
				echo " - Measuring ${NUMFREQ} frequency values from RO${INDEX}"
				${FREQUENCY} -q -c ${NUMFREQ} -i ${INDEX} > "${OUT}/${SLUG0}_freq${INDEX}.txt"
				${DISTRIBUTION} -t "RO${INDEX} of n=[${LENGTH}]" "${OUT}/${SLUG0}_freq${INDEX}.txt" "${OUT}/${SLUG0}_freq${INDEX}_distrib.png"
			done

			# For all DIVIDERS
			for DIVIDER in "${DIVIDERS[@]}"
			do
				# Refine the slug
				SLUG1="${SLUG0}_d${DIVIDER}"

				# Reprogram the FPGA after each measurement
				echo " - Reprogram FPGA"
				${VIVADO} -mode batch -source program_bitstream.tcl -tclargs "${OUT}/${SLUG0}_target.bit" > "${OUT}/${SLUG1}_vivado.log"

				# If COSO
				if [[ ${DIGITIZER} = 'coso' ]]
				then
					# Get random counter values and plot the COSO
					echo " - Reading ${NUMRAND} random values with DIVIDER=${DIVIDER}"
					${READRNG} -c ${NUMRAND} -m word "${OUT}/${SLUG1}_counters.txt" > "${OUT}/${SLUG1}_readrng.log"
					${DISTRIBUTION} -l -t "COSO n=[${LENGTH}]" "${OUT}/${SLUG1}_counters.txt" "${OUT}/${SLUG1}_distrib.png"

					# Extract LSB from counter values and convert to binary
					${TOBINARY} "${OUT}/${SLUG1}_counters.txt" "${OUT}/${SLUG1}.bin" > "${OUT}/${SLUG1}_tobinary.log"

				# If ERO or MURO
				else
					# Get random bits
					echo " - Reading ${NUMRAND} random bits with DIVIDER=${DIVIDER}"
					${READRNG} -d ${DIVIDER} -c  ${NUMRAND} -m bits "${OUT}/${SLUG1}_bits.txt" > "${OUT}/${SLUG1}_readrng.log"

					# Convert text bits to binary
					${TOBINARY} "${OUT}/${SLUG1}_bits.txt" "${OUT}/${SLUG1}.bin" > "${OUT}/${SLUG1}_tobinary.log"
				fi

				# Compute the entropy and put in a file
				VALUE=`${ENTROPY} -q -e mcv "${OUT}/${SLUG1}.bin"`
				echo "${DIGITIZER};${LENGTH};${DIVIDER};${TAKE};${VALUE}" >> "${OUT}/entropy.txt"
			done
		done
	done
done
