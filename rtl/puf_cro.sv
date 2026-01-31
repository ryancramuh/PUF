`timescale 1ns/1ps

// prevents synthesis optimizations
(* dont_touch = "yes" *)

// prevents cross-module optimizations
(* keep_hierarchy = "yes" *)

module puf_cro(
	input [5:0] challenge, // challenge[5:0] = {sel[0:2],bx[0:2]}
	input en,              // RO en
	output logic o         // output taken from the latch output of the third stage
);

	// first stage (has an en for the entire circuit)
	logic slice0_o; 
	logic slice0_l_o;

	// second stage
	logic slice1_o;
	logic slice1_l_o;

	// third stage
	logic slice2_o;
	logic slice2_l_o;

	// aptly named puf_slice_en has a global RO enable, unlike puf_slice
	puf_slice_en slice_zero(
		.d0(slice2_l_o),
		.d1(slice2_o),
		.sel(challenge[5]),
		.en(en),
		.bx(challenge[2]),
		.o(slice0_o),
		.l_o(slice0_l_o)
	);

	// puf_slice does not have RO en but has the latch en
	puf_slice slice_one(
		.d0(slice0_l_o),
		.d1(slice0_o),
		.sel(challenge[4]),
		.en(en),
		.bx(challenge[1]),
		.o(slice1_o),
		.l_o(slice1_l_o)
	);

	// final stage (need odd N for ring-oscillator)
	puf_slice slice_two(
		.d0(slice1_l_o),
		.d1(slice1_o),
		.sel(challenge[3]),
		.en(en),
		.bx(challenge[0]),
		.o(slice2_o),
		.l_o(slice2_l_o)
	);

	assign o = slice2_l_o;

endmodule
