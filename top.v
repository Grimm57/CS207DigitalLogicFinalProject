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
input on_off_btn,             // 开关机按钮
input menu_btn,               // 菜单按钮
input mode1_btn,              // 1档按钮
input mode2_btn,              // 2档按钮
input mode3_btn,              // 3档按钮
input mode_self_clean_btn,    // 自清洁按钮
output machine_state          // 开机状态
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
    .machine_state(machine_state));

    reg [2:0] mode_state;      // 模式状态 000待机 001一档 010二档 011三档（飓风） 100自清洁
    reg menu_led_state;        // 菜单键上方LED的显示状态，反映菜单键状态
    
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

    //其实这里可以再写个FSM出来
    always @ (posedge clk or negedge rst) begin
        if (~rst) begin
            mode_state <= 3'b000;       // 默认恢复待机状态
            menu_led_state <= 1'b0;
        end else begin
            if (machine_state) begin
                // 设备开启时，按菜单按钮切换风力模式
                if (menu_btn) begin
                    menu_led_state <= 1'b1;
                    if (mode1_btn) mode_state <= 3'b001;
                    else if (mode2_btn) mode_state <= 3'b010;
                    else if (mode3_btn) mode_state <= 3'b011;
                    else if (mode_self_clean_btn) mode_state <= 3'b100;
                    else mode_state <= 3'b000;
                    // ###### 设置相关的按钮还没做 
                end else begin
                    menu_led_state <= 1'b0;
                end
            end else begin
                mode_state <= 3'b000;
                menu_led_state <= 1'b0;
            end
        end
    end

    // 输出LED信号 （可以放在油烟机模块里，还没放）
    assign led[0] = on_off_btn;          // 第一个LED：表示开机状态（只有开机时会亮）
    assign led[1] = led_menu;            // 第二个LED：表示按下菜单按钮
    assign led[2] = led_mode1;           // 第三个LED：表示按下1档按钮
    assign led[3] = led_mode2;           // 第四个LED：表示按下2档按钮
    assign led[4] = led_mode3;           // 第五个LED：表示按下3档按钮

endmodule

