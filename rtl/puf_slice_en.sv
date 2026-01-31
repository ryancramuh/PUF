`timescale 1ns/1ps

// avoids synthesizer optimizations
(* dont_touch = "yes" *)

module puf_slice_en(
	input d0,   // latch output
	input d1,   // mux output
	input sel,  // challenge[5]
	input en,   // challenge[2]
	input bx,
	output logic o,
	output logic l_o
); 

	// keep ensure wires are not combined and optimized away
	(* keep = "true" *) wire m1 = sel ? ~d1 : ~d0;
	(* keep = "true" *) wire m2 = sel ? ~d1 : ~d0;
	(* keep = "true" *) wire e1 = en ?  m1 :  1'b0; // these enable mux control the whole CRO
	(* keep = "true" *) wire e2 = en ?  m2 :  1'b0; // these enable mux control the whole CRO 
	(* keep = "true" *) wire b = bx ? e2 : e1;
	
	assign o = b; // o is the mux output
	
	always_latch
		if(en)
			l_o <= b; // l_o is the latched version of the mux output

endmodule
