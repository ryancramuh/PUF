`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2026 05:36:36 PM
// Design Name: 
// Module Name: tb_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_counter();

    logic clr;
    logic clk;
    logic up;
    logic [3:0] cnt;
    logic rco;
    
    counter #(.N(4)) cntr(
        .clk(clk),
        .clr(clr),
        .up(up),
        .cnt(cnt),
        .rco(rco)
    );
    
    /* Uncomment to dump to wave file
    initial begin 
        $dumpfile("tb_counter.vcd");
        $dumpvars(0, tb_counter);
    end
    */
    
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end
    
    int i = 0; 
    
    event etrig;
    always@(etrig)
        begin
                clr <= 0;
                up <= 1;
        end
        
    always begin
        
        clr = 1'b1;
        up  = 1'b1;
        
        for(i = 0; i < 18; i++) begin
            #10
                ->etrig;
                $display("$stime,,,counter count = %d\n", cntr.cnt);
        end
        
        #10 $finish;
    end
endmodule
