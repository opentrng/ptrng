VSIM=vsimk

all:
	@echo "Please select one target: compile, gui or run"

compile:
	${VSIM} -c -do "do compile.tcl; exit"

gui:
	@[ "${TESTBENCH}" ] || ( echo "TESTBENCH is not set"; exit 1 )
	${VSIM} -t fs work.${TESTBENCH} -voptargs=+acc -do "do wave_${TESTBENCH}.tcl"

run:
	@[ "${TESTBENCH}" ] || ( echo "TESTBENCH is not set"; exit 1 )
	@[ "${DURATION}" ] || ( echo "DURATION is not set"; exit 1 )
	${VSIM} -c -t fs work.${TESTBENCH} -do "run ${DURATION}; exit"
