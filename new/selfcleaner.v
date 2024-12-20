`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/12 10:50:53
// Design Name: 
// Module Name: selfcleaner
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


module selfcleaner(
    input clk,
    input rst,
    input [2:0] mode_state,      
    input menu_btn,
    input self_clean_btn,
    output reg led_self_clean,
    output [7:0] digit1,
    output [7:0] digit2,
    output [7:0] tube_sel
);
    wire clk_1hz;
    
    ClockDivider1Hz ClockDivider1Hz(
        .clk(clk),
        .rst(rst),
        .clk_out(clk_1hz)
    );
    

    wire [7:0] clean_digit1, clean_digit2, clean_tube_sel;
    reg [7:0] digit1_reg, digit2_reg, tube_sel_reg;

    reg [5:0] sec = 0;          //倒计时秒数
    reg [5:0] minute = 3;       //倒计时分钟数


    //自清洁模式
    always @(posedge clk_1hz or negedge rst) begin
        if (!rst) begin
            minute <= 3;  // 复位时分钟数重新设置为 3
            sec <= 0;     // 复位时秒数重新设置为 0
        end else begin
            if (mode_state == 3'b100) begin
                // 自清洁模式开始时进行倒计时
                if (sec == 0 && minute > 0) begin
                    sec <= 59;     // 秒数归零后重置为 59
                    minute <= minute - 1; // 分钟数减 1
                end else if (sec > 0) begin
                    sec <= sec - 1; // 每秒倒计时减 1
                end
            end
        end

    end

    always @(minute or sec) begin
        if (minute == 0 && sec == 0) begin
            led_self_clean <= 1;  // 倒计时结束，设置指示器为1
        end else begin
            led_self_clean <= 0;  // 倒计时未结束，保持指示器为0
        end
    end

    reg [31:0] time_data;
    
    // 将分钟和秒数转换为合适的时间格式（分:秒）
    always @(minute or sec) begin
        time_data[31:28] = 4'b0000;           // 时部分设置为 0
        time_data[27:24] = 4'b0000;           // 时部分设置为 0
        time_data[23:20] = 4'b1111;           // 分隔符
        time_data[19:16] = minute / 10;       // 分钟的十位数
        time_data[15:12] = minute % 10;       // 分钟的个位数
        time_data[11:8]  = 4'b1111;           // 分隔符
        time_data[7:4]   = sec / 10;          // 秒的十位数
        time_data[3:0]   = sec % 10;          // 秒的个位数
    end
    
    // 使用时间显示模块显示倒计时
    timeDisplay timeDisplay(
        .clk(clk),
        .rst(rst),
        .time_data(time_data),
        .digit1(digit1),
        .digit2(digit2),
        .tube_sel(tube_sel)
    );
  

    // 输出信号
    assign digit1 = digit1_reg;
    assign digit2 = digit2_reg;
    assign tube_sel = tube_sel_reg;

endmodule


