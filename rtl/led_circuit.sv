`timescale 1ns/1ps

module led_circuit(
	input clk,
	input [6:0] sw,
	output logic [15:0] led
);

	logic [19:0] cnt;
	logic [19:0] cnt2;
	
	puf_cro cro(
		.challenge(sw[5:0]),
		.en(sw[6]),
		.o(up)
	);

	always_ff@(posedge clk)
		case(sw[6])
			1'b0: cnt <= 0;
			1'b1: cnt <= cnt + 1;
		endcase

	always_ff@(posedge up);
		case(sw[6])
			1'b0: cnt2 <= 0;
			1'b1: cnt2 <= cnt2 + 1;
		endcase

	always_latch 
		if(cnt == 20'hFFFFF)
			led <= cnt2[15:0];
	
endmodule
