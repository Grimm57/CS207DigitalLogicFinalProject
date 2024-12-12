`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/10 23:26:16
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
input clk,                    // 时钟信号
input rst,                    // 复位信号

input left_btn,               // 左键
input right_btn,              // 右键
input gesture_btn_state,      // 1: 切换到手势按键

input on_off_btn,             // 开关机按钮
output machine_state          // 开机状态

input menu_btn,               // 菜单按钮（非待机模式按菜单键返回待机）
input mode1_btn,              // 1档按钮
input mode2_btn,              // 2档按钮
input mode3_btn,              // 3档按钮
input mode_self_clean_btn,    // 自清洁按钮

output [7:0] digit1,          // 数码管显示的数字1
output [7:0] digit2,          // 数码管显示的数字2
output [7:0] tube_sel,        // 数码管选择信号
output [4:0] led              // LED信号
    );
    wire clk_1hz;             // 1Hz 时钟信号

    //实例化1Hz分频器
    ClockDivider1Hz clock1hzzzz(.clk(clk),.rst(rst),.clk_out(clk_1hz));
    
    //实例化开关机模块
    onOffControl on_off_control(
    .clk(clk),
    .reset(rst),
    .left_btn(left_btn),
    .right_btn(right_btn),
    .on_off_btn(on_off_btn),
    .gesture_btn_state(gesture_btn_state),
    .machine_state(machine_state));

    reg [2:0] mode_state;      // 模式状态 000待机 001一档 010二档 011三档（飓风） 100自清洁
    
    //实例化油烟机模块
    smoker smoker_inst (
        .clk(clk),
        .rst(rst),
        .mode_state(mode_state),        // 传递模式状态
        .menu_btn(menu_btn),
        .mode1_btn(mode1_btn),
        .mode2_btn(mode2_btn),
        .mode3_btn(mode3_btn),
        .digit1(digit1),                // 数码管显示的数字1
        .digit2(digit2),                // 数码管显示的数字2
        .tube_sel(tube_sel),            // 数码管选择信号
        .led_mode1(led_mode1),
        .led_mode2(led_mode2),
        .led_mode3(led_mode3)
    );

    //实例化模式选择模块
    mode_fsm mode_fsm_inst (
        .clk(clk),
        .rst(rst),
        .menu_btn(menu_btn),
        .mode1_btn(modo1_btn),
        .mode2_btn(mode2_btn),
        .mode3_btn(mode3_btn),
        .mode_self_clean_btn(mode_self_clean_btn),
        .mode_state(mode_state),
        .led(led)
    );

endmodule

