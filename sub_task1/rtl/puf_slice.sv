`timescale 1ns/1ps

// avoids synthesizer optimizations
(* dont_touch = "yes" *)

module puf_slice(
	input d0,
	input d1,
	input sel,
	input en,
	input bx,
	output logic o,
	output logic l_o
); 
	// keep allows us to avoid optimizations
	// here m1 and m2 would be optimized to form 1 signal
	(* keep = "true" *) wire m1 = sel ? ~d1 : ~d0;
	(* keep = "true" *) wire m2 = sel ? ~d1 : ~d0;
	(* keep = "true" *) wire b = bx ? m2 : m1;

	// o = the mux output
	assign o = b;
	
	always_latch
		if(en)
			l_o <= b; // l_o = latched version of the mux output

endmodule
