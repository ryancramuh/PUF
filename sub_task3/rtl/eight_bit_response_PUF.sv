`timescale 1ns/1ps

// ensure synthesizer doens't touch this 
(* dont_touch = "yes" *)

module eight_bit_response_PUF
(
    input               rst, // global reset for FSM
	input               clk, // global clock
	input [5:0]         sw,  // Basys 3 switches
	input               en,    
	output logic [7:0] led,  // Basys 3 LEDs
	output logic done        // let's us know when PUF is done
);

	logic        r0;   // output of RO 0
	logic        r1;   // output of RO 1
	logic        r2;   // output of RO 2
	logic        r3;   // output of RO 3
	logic        r4;   // output of RO 4
	logic        r5;   // output of RO 5
	logic        r6;   // output of RO 6
	logic        r7;   // output of RO 7
	logic        r8;   // output of RO 8
	
	logic ro_mux_o;    // which RO we are looking at
    logic [3:0] sel;    // we look at RO 0, then RO 1
    logic next;
    logic max;
    
    logic [5:0] captured_sw; // flip flopped value of switches
    logic recalc;        // recalculate result;
    
    logic [3:0] ld_addr;  // which ro cnt we are loading
    logic [3:0] clr_addr; // which ro cnt we are clearning
	
	logic        clr_ro; // clear the RO counter
	logic [24:0] ro_cnt; // the current # of RO posedge's we've seen
	
	logic        std_up;     // increment the std_cntr on the posedge of clk    
	logic        clr_std;    // clear the std cntr before examining an RO
	logic        capture_ro; // get the RO counter count
	
	logic clr_reg;   // clr the ro_cnts at clr_addr 
	logic clr_start; // clr the ro_cnts at [0]
	logic ld_reg;    // ld the ro_cnts at [ld_addr]
	
	logic [24:0] ro_cnts [0:8];  // 9 RO counts to generate 8 response bits
	logic [7:0] response_buffer; // where we output the PUF response 
	
    
    // if RO_N counter larger than RO_N-1 counter
    logic gt;
    
    // flip flops for synchronization
    logic ro_sync1, ro_sync2, ro_sync2_d;
    logic ro_rise = (ro_sync2 && !ro_sync2_d);  // ro's rising edge in the clk domain

    assign max = sel == 8; // let's us know when we are done
     
	// Configurable Ring Oscillator 0
	puf_cro cro0(
		.challenge(sw[5:0]),
		.en(en),
		.o(r0)
	);
	
	// Configurable Ring Oscillator 1
	puf_cro cro1(
	   .challenge(sw[5:0]),
	   .en(en),
	   .o(r1)
	);
	
	// Configurable Ring Oscillator 2
	puf_cro cro2(
	   .challenge(sw[5:0]),
	   .en(en),
	   .o(r2)
	);
    
    // Configurable Ring Oscillator 3
	puf_cro cro3(
	   .challenge(sw[5:0]),
	   .en(en),
	   .o(r3)
	);
	
	// Configurable Ring Oscillator 4
	puf_cro cro4(
	   .challenge(sw[5:0]),
	   .en(en),
	   .o(r4)
	);
	
	// Configurable Ring Oscillator 5
	puf_cro cro5(
	   .challenge(sw[5:0]),
	   .en(en),
	   .o(r5)
	);
	
	// Configurable Ring Oscillator 6
	puf_cro cro6(
	   .challenge(sw[5:0]),
	   .en(en),
	   .o(r6)
	);
	
	// Configurable Ring Oscillator 7
	puf_cro cro7(
	   .challenge(sw[5:0]),
	   .en(en),
	   .o(r7)
	);
	
	
	// Configurable Ring Oscillator 8
	puf_cro cro8(
	   .challenge(sw[5:0]),
	   .en(en),
	   .o(r8)
	);
	
	// RO MUX
    always_comb begin
        case(sel)
            4'b0000: ro_mux_o = r0;
            4'b0001: ro_mux_o = r1;
            4'b0010: ro_mux_o = r2;
            4'b0011: ro_mux_o = r3;
            4'b0100: ro_mux_o = r4;
            4'b0101: ro_mux_o = r5;
            4'b0110: ro_mux_o = r6;
            4'b0111: ro_mux_o = r7;
            4'b1000: ro_mux_o = r8;
            default: ro_mux_o = r0;
        endcase
    end
    
    // std_counter @50Mhz
    counter #(.N(25)) std_counter(
        .clk(clk),
        .clr(clr_std | rst),
        .up(std_up),
        .cnt(),
        .rco(capture_ro)
    );
    

     // double flip flop synchronizer 
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
            
    // Register File for RO counter
    always_ff@(posedge clk) begin
        if(rst) begin
            ro_cnts[0] <= 0;
        end else if(clr_start) begin
            ro_cnts[0] <= 0;
        end else if(ld_reg) begin
            ro_cnts[ld_addr] <= ro_cnt;
            if(clr_reg) begin
                ro_cnts[clr_addr] <= 0;
            end
        end else begin
            ro_cnts <= ro_cnts;
        end
    end
    
    // Block that selects which
    // ro_cnts register to clear and load
    always_comb begin
        ld_addr = 4'd0;
        clr_addr = 4'd0;
        case(sel)
            4'd0: begin
                ld_addr = 4'd0;
                clr_addr = 4'd1;
            end
            4'd1: begin
                ld_addr = 4'd1;
                clr_addr = 4'd2;
            end
            4'd2: begin
                ld_addr = 4'd2;
                clr_addr = 4'd3;
            end
            4'd3: begin
                ld_addr = 4'd3;
                clr_addr = 4'd4;
            end
            4'd4: begin
                ld_addr = 4'd4;
                clr_addr = 4'd5;
            end
            4'd5: begin
                ld_addr = 4'd5;
                clr_addr = 4'd6;
            end
            4'd6: begin
                ld_addr = 4'd6;
                clr_addr = 4'd7;
            end
            4'd7: begin
                ld_addr = 4'd7;
                clr_addr = 4'd8;
            end
            4'd8: begin
                ld_addr = 4'd8;
                clr_addr = 4'd0;
            end
            default: begin
                ld_addr = 4'd0;
                clr_addr = 4'd0;
            end
        endcase
    end
    
    // SEL counter activated by next
    always_ff@(posedge clk) 
        if(rst)
            sel <= 0;
        else if(next || done)
            sel <= sel + 1;
        else
            sel <= sel;
    
    // Comparator calculates the responses if done
    always_comb begin
        if(done) begin
            response_buffer[0] = ro_cnts[0] > ro_cnts[1];
            response_buffer[1] = ro_cnts[1] > ro_cnts[2];
            response_buffer[2] = ro_cnts[2] > ro_cnts[3];
            response_buffer[3] = ro_cnts[3] > ro_cnts[4];
            response_buffer[4] = ro_cnts[4] > ro_cnts[5];
            response_buffer[5] = ro_cnts[5] > ro_cnts[6];
            response_buffer[6] = ro_cnts[6] > ro_cnts[7];
            response_buffer[7] = ro_cnts[7] > ro_cnts[8];
        end
        else begin
            response_buffer = 0;
        end
    end
    
    // flop captures the switches
    always_ff@(posedge clk)
	   captured_sw <= sw;
	
	// if captured switches 
	// do not equal current switches
	// then recalculate
	always_comb 
	   if(captured_sw != sw) 
	       recalc = 1'b1;
	   else
	       recalc = 1'b0;
    
    // Get Eight Response State Machine:
    
        /*
            1. Waits for EN (sw[6])
            2. Counts for 1.35 seconds then captures RO_0 counter in reg_0
            3. Counts for 1.35 seconds then captures RO_1 counter in reg_1
            4. Compares reg0 and reg1, displays led, and displays a second led if reg 0 > reg1
       */
       
	logic [1:0] NS, PS;
	parameter INIT = 2'b00;
	parameter GET_RO = 2'b01;
	parameter DONE = 2'b10;

    always_comb begin
        NS = PS;
        clr_ro = 1'b0;
        clr_std = 1'b0;
        clr_reg = 1'b0;
        clr_start = 1'b0;
        ld_reg = 1'b0;
        std_up = 1'b0;
        next = 1'b0;
        led = 8'b0000_0000;
        done = 1'b0;
        
        
        case(PS)
            
            INIT: begin
                if(recalc) begin
                    NS = INIT;
                end
                else if(en) begin
                    clr_ro = 1'b1;
                    clr_std = 1'b1;
                    clr_start = 1'b0;
                    NS = GET_RO;
                end else begin
                    NS = INIT;
                end
            end 
            
            GET_RO: begin
                if(recalc) begin
                    clr_ro = 1'b1;
                    clr_std = 1'b1;
                    NS = INIT;
                end
                else if(max && capture_ro) begin
                    ld_reg = 1'b1;
                    clr_reg = 1'b0;
                    clr_ro = 1'b1;
                    clr_std = 1'b1;
                    NS = DONE;
                end
                else if(capture_ro) begin
                    ld_reg = 1'b1;
                    clr_reg = 1'b1;
                    clr_ro = 1'b1;
                    clr_std = 1'b1;
                    next = 1'b1;
                    NS = GET_RO;
                end else begin
                    std_up = 1'b1;
                    NS = GET_RO;
                end
            end
            
            DONE: begin
                if(recalc) begin
                    led = 0;
                    done = 1'b0;
                    clr_ro = 1'b1;
                    clr_std = 1'b1;
                    NS = INIT;
                end else begin
                    led = response_buffer;
                    done = 1'b1;
                    NS = DONE;
                end
            end
            
            default: begin
            
                NS = INIT;
            end
            
        endcase
        
    end
    
	always_ff@(posedge clk)
	   if(rst)
	       PS <= INIT;
	   else
	       PS <= NS;
	       

endmodule
