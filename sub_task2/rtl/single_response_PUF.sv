`timescale 1ns/1ps

// ensure synthesizer doens't touch this 
(* dont_touch = "yes" *)

module single_response_PUF
(
    input               rst, // global reset for FSM
	input               clk, // global clock
	input [6:0]         sw,  // Basys 3 switches
	
	output logic [1:0] led  // Basys 3 LEDs
);

	logic        r0;   // output of RO 0
	logic        r1;   // output of RO 1
	
	logic ro_mux_o;    // which RO we are looking at
    logic sel;         // we look at RO 0, then RO 1
	
	logic        clr_ro; // clear the RO counter
	logic [25:0] ro_cnt; // the current # of RO posedge's we've seen
	
	logic        std_up;     // increment the std_cntr on the posedge of clk    
	logic        clr_std;    // clear the std cntr before examining an RO
	logic        capture_ro; // get the RO counter count
	
	// register 0 holds RO 0 counter
	logic clr_reg0;
    logic ld_reg0;
    logic [25:0] reg0;
    
    // register 1 holds RO 1 counter 
    logic clr_reg1;
    logic ld_reg1;
    logic [25:0] reg1;
    
    // if RO_0 counter larger than RO_1 counter
    logic gt;
    
    // flip flops for synchronization
    logic ro_sync1, ro_sync2, ro_sync2_d;
    logic ro_rise = (ro_sync2 && !ro_sync2_d);  // ro's rising edge in the clk domain

    

	// Configurable Ring Oscillator 0
	puf_cro cro0(
		.challenge(sw[5:0]),
		.en(sw[6]),
		.o(r0)
	);
	
	// Configurable Ring Oscillator 1
	puf_cro cro1(
	   .challenge(sw[5:0]),
	   .en(sw[6]),
	   .o(r1)
	);
    
    (* keep = "true" *) assign ro_mux_o = sel ? r1 : r0;
    
    // std_counter @50Mhz
    counter #(.N(26)) std_counter(
        .clk(clk),
        .clr(clr_std | rst),
        .up(std_up),
        .cnt(),
        .rco(capture_ro)
    );
    

    
    always_ff @(posedge clk) begin
      if (rst) begin
        ro_sync1   <= 1'b0;
        ro_sync2   <= 1'b0;
        ro_sync2_d <= 1'b0;
      end else begin
        ro_sync1   <= ro_mux_o;
        ro_sync2   <= ro_sync1;
        ro_sync2_d <= ro_sync2;
      end
    end
    

    // ro_cnt counted in clk domain
    always_ff @(posedge clk) begin
      if (rst || clr_ro) begin
        ro_cnt <= '0;
      end else if (ro_rise) begin
        ro_cnt <= ro_cnt + 1'b1;
      end
    end

    // register 0
    always_ff@(posedge clk)
        if(clr_reg0 || rst)
            reg0 <= 0;
        else if(ld_reg0)
            reg0 <= ro_cnt;
        else
            reg0 <= reg0;
            
    // register 1
    always_ff@(posedge clk)
        if(clr_reg1 || rst)
            reg1 <= 0;
        else if(ld_reg1)
            reg1 <= ro_cnt;
        else
            reg1 <= reg1;
    
    // comparator for response bit
    always_comb
        if(reg0 > reg1)
            gt = 1'b1;
        else
            gt = 1'b0;
            
    // Get Single Response State Machine:
    
        /*
            1. Waits for EN (sw[6])
            2. Counts for 1.35 seconds then captures RO_0 counter in reg_0
            3. Counts for 1.35 seconds then captures RO_1 counter in reg_1
            4. Compares reg0 and reg1, displays led, and displays a second led if reg 0 > reg1
       */
       
	logic [1:0] NS, PS;
	parameter INIT = 2'b00;
	parameter GET_RO_ZERO = 2'b01;
	parameter GET_RO_ONE = 2'b10;
	parameter DONE = 2'b11;

    always_comb begin
        NS = PS;
        sel = 1'b0;
        clr_ro = 1'b0;
        clr_std = 1'b0;
        clr_reg0 = 1'b0;
        clr_reg1 = 1'b0;
        ld_reg0 = 1'b0;
        ld_reg1 = 1'b0;
        std_up = 1'b0;
        led = 2'b00;
        
        case(PS)
            
            INIT: begin
                if(sw[6]) begin
                    clr_ro = 1'b1;
                    clr_std = 1'b1;
                    clr_reg0 = 1'b1;
                    clr_reg1 = 1'b1;
                    NS = GET_RO_ZERO;
                end else begin
                    NS = INIT;
                end
            end 
            
            GET_RO_ZERO: begin
                sel = 1'b0;
                if(capture_ro) begin
                    ld_reg0 = 1'b1;
                    clr_ro = 1'b1;
                    clr_std = 1'b1;
                    NS = GET_RO_ONE;
                end else begin
                    std_up = 1'b1;
                    NS = GET_RO_ZERO;
                end
            end
            
            GET_RO_ONE: begin
                sel = 1'b1;
                if(capture_ro) begin
                    ld_reg1 = 1'b1;
                    clr_ro = 1'b1;
                    clr_std = 1'b1;
                    NS = DONE;
                end else begin
                    std_up = 1'b1;
                    NS = GET_RO_ONE;
                end
            end
            
            DONE: begin
                led = {1'b1, gt};
                NS = DONE;
            end
            
        endcase
        
    end
	always_ff@(posedge clk)
	   if(rst)
	       PS <= INIT;
	   else
	       PS <= NS;
endmodule
