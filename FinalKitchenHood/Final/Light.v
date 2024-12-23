`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/22 11:16:16
// Design Name: 
// Module Name: light
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


module light(
input clk,
input rst,
input light_sw,
input machine_state,
output reg light_led
    );
    
    always @ (posedge clk) begin
        if (~rst) begin
            light_led <= 1'b0;
        end
        else begin
            if (machine_state) begin
                if (light_sw) light_led <= 1'b1;
                else light_led <= 1'b0;
            end
        end
    end
endmodule