`timescale 1ns/1ps

module puf_slice_en(
	input d0,
	input d1,
	input sel,
	input en,
	input bx,
	output logic o,
	output logic l_o
); 
	
	assign wire m1 = sel ? ~d1 : ~d0;
	assign wire m2 = sel ? ~d1 : ~d0;
	assign wire e1 = sel ?  m1 :  1'b0;
	assign wire e2 = sel ?  m2 :  1'b0;
	assign wire b  = bx ?  e2 :  e1;
	
	always_latch
		if(en)
			l_o <= b;

endmodule
