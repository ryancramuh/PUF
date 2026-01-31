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
	logic [19:0] cnt;  // clock divider counter
	logic [19:0] cnt2; // RO posedge counter
	
	puf_cro cro(
		.challenge(sw[5:0]),
		.en(sw[6]),
		.o(up)
	);

	always_ff@(posedge clk)
		if((sw[6] == 1'b1))
			cnt <= cnt + 1;
		else
			cnt <= 0;

	always_ff@(posedge up)
			cnt2 <= cnt2 + 1;

	always_latch 
		if(cnt == 20'hFFFFF)
			led <= cnt2[15:0];
	
endmodule
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
	logic [19:0] cnt;  // clock divider counter
	logic [19:0] cnt2; // RO posedge counter

	// instantiate the CRO (now as a hard macro pblock)
	puf_cro cro(
		.challenge(sw[5:0]), // challenge[5:0] = {sel[0:2],bx[0:2}
		.en(sw[6]),          // sw[6] is the enable 
		.o(up)               // the latch output of the third stage is our counter trigger
	);

	always_ff@(posedge clk)
		if((sw[6] == 1'b1))
			cnt <= cnt + 1;
		else
			cnt <= 0;

	always_ff@(posedge up) // if up, cnt2 <= cnt2 + 1
			cnt2 <= cnt2 + 1;

	always_latch 
		if(cnt == 20'hFFFFF) // If count = max 
			led <= cnt2[15:0];
	
endmodule
