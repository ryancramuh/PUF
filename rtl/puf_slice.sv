`timescale 1ns/1ps

module puf_slice(
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
	assign wire b  = bx ?  m2 :  m1;
	
	always_latch
		if(en)
			l_o <= b;

endmodule
