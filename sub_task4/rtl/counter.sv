`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2026 05:32:43 PM
// Design Name: 
// Module Name: counter
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


module counter
#(
parameter N = 32
)
(
    input clk,
    input up,
    input clr,
    output logic [N-1:0] cnt,
    output logic rco
);

    always_ff@(posedge clk)
        if(clr)
            cnt <= 0;
        else if(up)
            cnt <= cnt + 1;
        else
            cnt <= cnt;
            
    assign rco = cnt == (2**N)-1;
    
endmodule
