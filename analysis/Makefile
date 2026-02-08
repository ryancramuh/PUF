TOP := calc_hamming

SIM := iverilog
SIM_ARGS := -g2012 -o

.PHONY: analysis

analysis:
	@ if [ -z "$$TOP.sv" ]; then \
		echo " \033[31m Please specify a file to analyze \033[0m"; \
		return 2; \
	fi
	@ $(SIM) $(SIM_ARGS) $(TOP).vvp $(TOP).sv
	@ echo "\033[32m simulating: \033[0m \n"
	@ vvp $(TOP).vvp
