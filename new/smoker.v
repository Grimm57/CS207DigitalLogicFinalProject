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

module smoker (
    input clk,                    // 原始时钟信号（例如500Hz）
    input rst,                    // 复位信号
    input [2:0] mode_state,       // 当前工作模式输入（0：待机，1：1档，2：2档，3：3档）
    input menu_btn,               //用于按下菜单键60s关闭三档
    output [7:0] digit1,          // 数码管显示的数字1
    output [7:0] digit2,          // 数码管显示的数字2
    output [7:0] tube_sel,        // 数码管选择信号
    output reg return_state,      //输出三档结束后要变回的状态
    output reg hurricane_mode_enabled,    // 飓风模式是否可以启用（只能使用一次）
    output reg meun_btn_pressed //用来看是否在三档时按下了菜单键
);

    wire clk_1hz;
    ClockDivider1Hz u_clk_divider (
        .clk(clk),
        .rst(rst),
        .clk_out(clk_1hz)   // 输出 1Hz 时钟
    );
    
    // 控制风力模式

    
    

    // 计时信号
    reg [5:0] cumulative_time_min; // 累计分钟
    reg [5:0] cumulative_time_sec; // 累计秒数
    reg [5:0] countdown_time_min;  // 倒计时分钟
    reg [5:0] countdown_time_sec;  // 倒计时秒数

    // 控制风力模式
    always @(posedge clk_1hz or negedge rst) begin
        if (!rst) begin
            cumulative_time_sec <= 0;
            cumulative_time_min <= 0;
            countdown_time_sec <= 0;
            countdown_time_min <= 1;
            hurricane_mode_enabled <= 1;
            meun_btn_pressed <=0;
            return_state <=1;
        end else begin
            if (mode_state == 3'b001) begin
            // 1档风力
                if (cumulative_time_sec == 59) 
                    begin
                        cumulative_time_sec <= 0;
                        if (cumulative_time_min == 59) begin
                            cumulative_time_min <= 0;
                        end else begin
                            cumulative_time_min <= cumulative_time_min + 1;
                        end
                    end else begin
                        cumulative_time_sec <= cumulative_time_sec + 1;
                end
            end else if (mode_state == 3'b010) begin
            // 2档风力
                if (cumulative_time_sec == 59) begin
                        cumulative_time_sec <= 0;
                        if (cumulative_time_min == 59) begin
                            cumulative_time_min <= 0;
                        end else begin
                            cumulative_time_min <= cumulative_time_min + 1;
                        end
                    end else begin
                        cumulative_time_sec <= cumulative_time_sec + 1;
                end
            end else if (mode_state == 3'b011 & hurricane_mode_enabled) begin
                if(menu_btn) begin
                    meun_btn_pressed <=1;
                end
                if (countdown_time_sec == 0 & countdown_time_min == 0) begin  //倒计时结束，返回某个状态
                    if(meun_btn_pressed)begin
                        //回到待机
                        return_state <=0;
                    end else begin
                        //回到二挡
                        return_state <=1;
                    end
                    hurricane_mode_enabled <= 0;  // 只能使用一次
                        end else if (countdown_time_sec == 0) begin
                            if (countdown_time_min > 0) begin
                                countdown_time_min <= countdown_time_min - 1;
                                countdown_time_sec <= 59;
                            end
                        end else begin
                            countdown_time_sec <= countdown_time_sec - 1;
                end
                    
            end
        end
    end


    // 将累计时间转换为time_data格式
    reg [31:0] cumulative_time_data;
    always @(posedge clk_1hz) begin
        cumulative_time_data[31:28] = 4'b0000;           // 时部分设置为 0
        cumulative_time_data[27:24] = 4'b0000;           // 时部分设置为 0
        cumulative_time_data[23:20] = 4'b1111;           // 分隔符
        cumulative_time_data[19:16] = cumulative_time_min / 10;       // 分钟的十位数
        cumulative_time_data[15:12] = cumulative_time_min % 10;       // 分钟的个位数
        cumulative_time_data[11:8]  = 4'b1111;           // 分隔符
        cumulative_time_data[7:4]   = cumulative_time_sec / 10;          // 秒的十位数
        cumulative_time_data[3:0]   = cumulative_time_sec % 10;          // 秒的个位数
    end

    // 将倒计时转换为time_data格式
    reg [31:0] countdown_time_data;
    always @(posedge clk_1hz) begin
        countdown_time_data[31:28] = 4'b0000;           // 时部分设置为 0
        countdown_time_data[27:24] = 4'b0000;           // 时部分设置为 0
        countdown_time_data[23:20] = 4'b1111;           // 分隔符
        countdown_time_data[19:16] = countdown_time_min / 10;       // 分钟的十位数
        countdown_time_data[15:12] = countdown_time_min % 10;       // 分钟的个位数
        countdown_time_data[11:8]  = 4'b1111;           // 分隔符
        countdown_time_data[7:4]   = countdown_time_sec / 10;          // 秒的十位数
        countdown_time_data[3:0]   = countdown_time_sec % 10;          // 秒的个位数
    end

    // 控制显示切换
    reg display_select =0;  // 用于选择显示哪个时间（0: 累计时间, 1: 倒计时）
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            display_select <= 0;  // 复位时，默认显示累计时间
        end else if (mode_state == 3'b010 | mode_state == 3'b001) begin
            display_select <= 0;  // 显示累计时间
        end else if (mode_state == 3'b011) begin
            display_select <= 1;  // 在飓风模式下显示倒计时
        end
    end


    // 根据显示选择输出相应的时间数据
    reg [31:0] display_data;
    always @(display_select)begin
        if(display_select)begin
            display_data=countdown_time_data;
        end else begin
            display_data=cumulative_time_data;
        end
    end
    

    // 实例化timeDisplay模块
    timeDisplay u_time_display (
        .clk(clk),   
        .rst(rst),
        .time_data(display_data),
        .digit1(digit1),
        .digit2(digit2),
        .tube_sel(tube_sel)
    );

    


endmodule
