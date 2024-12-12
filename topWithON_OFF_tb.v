`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/06 09:00:54
// Design Name: 
// Module Name: top_tb
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


module top_tb(

    );
    reg left_btn, right_btn, menu_btn, mode1_btn,mode2_btn, mode3_btn, mode_self_clean_btn;
    reg reset,clk,on_off_btn;
    wire machine_state;
        
        
    top u_uf(
    .clk(clk),
//    .clk_1hz(clk_1hz),
    .reset(reset),
    .left_btn(left_btn),
    .right_btn(right_btn),
    .on_off_btn(on_off_btn),
    .menu_btn(menu_btn),
    .mode1_btn(mode1_btn),
    .mode2_btn(mode2_btn),
    .mode3_btn(mode3_btn),
    .mode_self_clean_btn(mode_self_clean_btn),
    .machine_state(machine_state));
    
    always begin
        #4 clk <= ~clk;
    end
    
    always begin
        #57 on_off_btn <= ~on_off_btn;
    end
    
    initial begin
        #0 reset <= 1'b1;
        #0 on_off_btn <= 1'b0;
        #0 clk <= 1'b0;
        #10 reset <= 1'b0;
    end
endmodule
