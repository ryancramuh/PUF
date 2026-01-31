`timescale 1ns/1ps

// ensure synthesizer doens't touch this 
(* dont_touch = "yes" *)

module led_circuit
(
	input               clk, // global clock
	input [6:0]         sw,  // Basys 3 switches
	
	output logic [15:0] led  // Basys 3 LEDs
);

	logic        up;   // posedge of RO     
	logic [25:0] cnt;  // RO posedge counter
	
	puf_cro cro(
		.challenge(sw[5:0]),
		.en(sw[6]),
		.o(up)
	);


	always_ff@(posedge up)
	   if(sw[6] == 1'b1)
			cnt <= cnt + 1;
	   
	always_ff@(posedge up)
	   if(sw[6] == 1'b0)
	       led <= 0;
	   else if(cnt == 26'h3FFFFFF)
	       led <= ~led;

	
endmodule
