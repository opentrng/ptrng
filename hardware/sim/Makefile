VSIM=vsimk

all:
	@echo "Please select one target: compile, gui or run"

compile:
	${VSIM} -c -do "do compile.tcl; exit"

gui:
	${VSIM} -t fs work.${TESTBENCH} -do "do wave_${TESTBENCH}.tcl"

run:
	${VSIM} -c -t fs work.${TESTBENCH} -do "run ${DURATION}; exit"
