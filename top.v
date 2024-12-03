`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/04 00:38:15
// Design Name: 
// Module Name: top
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


module top(
input on_off_btn,
input menu_btn,
input mode1_btn,
input mode2_btn,
input mode3_btn,
input mode_self_clean_btn,
output[5:0] current_time,
output[5:0] cumulative_time,
output[2:0] count_down_time
    );
    wire machine_state;
    wire[2:0] mode_state;// 0待机 000    1一档 001  2二档 010 3三档 011 4自清洁 100
    
    // 实现FSM进行mode_state转换
    // 实例化计时module
    // 实例化数码显示管module
    
    //在计时模块中和显示模块中，都要根据mode_state进行条件控制，匹配哪些可进行的操作
endmodule
