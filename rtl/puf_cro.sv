`timescale 1ns/1ps

module puf_cro(
	input [5:0] challenge,
	input en,
	output logic o
);

	logic slice0_o;
	logic slice0_l_o;
	
	logic slice1_o;
	logic slice1_l_o;

	logic slice2_o;
	logic slice2_l_o;

	puf_slice_en slice_zero(
		.d0(slice2_l_o),
		.d1(slice2_o),
		.sel(challenge[5]),
		.en(en),
		.bx(challenge[2]),
		.o(slice0_o),
		.l_o(slice0_l_o)
	);

	puf_slice slice_one(
		.d0(slice0_l_o),
		.d1(slice0_o),
		.sel(challenge[4]),
		.en(en),
		.bx(challenge[1]),
		.o(slice1_o),
		.l_o(slice1_l_o)
	);

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
