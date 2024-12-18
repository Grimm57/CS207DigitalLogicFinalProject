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
    input menu_btn,               // 菜单按钮
    input mode1_btn,              // 1档按钮
    input mode2_btn,              // 2档按钮
    input mode3_btn,              // 3档按钮
    output [7:0] digit1,          // 数码管显示的数字1
    output [7:0] digit2,          // 数码管显示的数字2
    output [7:0] tube_sel,        // 数码管选择信号
    output reg [2:0] mode_state_fix //更新mode_state(三档自动关闭时会更新为二挡，传回top中重新给mode_state赋值)
);

    // wire clk_1hz;
    // ClockDivider1Hz u_clk_divider (
    //     .clk(clk),
    //     .rst(rst),
    //     .clk_out(clk_1hz)   // 输出 1Hz 时钟
    // );
    
    // 控制风力模式

    reg is_in_hurricane_mode;      // 是否在飓风模式中
    reg hurricane_mode_enabled;    // 飓风模式是否启用（只能使用一次）
    

    // 计时信号
    reg [5:0] cumulative_time_min; // 累计分钟
    reg [5:0] cumulative_time_sec; // 累计秒数
    reg [5:0] countdown_time_min;  // 倒计时分钟
    reg [5:0] countdown_time_sec;  // 倒计时秒数

    // 控制风力模式
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            mode_state_fix <= 0;  // 默认待机模式
            cumulative_time_sec <= 0;
            cumulative_time_min <= 0;
            countdown_time_sec <= 0;
            countdown_time_min <= 1;
            is_in_hurricane_mode <= 0;
            hurricane_mode_enabled <= 1;
        end else begin
            if (mode_state == 3'b000) begin
            // 待机模式
            end else if (mode_state == 3'b001) begin
            // 1档风力
            begin 
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
                end
            end else if (mode_state == 3'b010) begin
            // 2档风力
            begin 
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
                end
            end else if (mode_state == 3'b011 && hurricane_mode_enabled && !is_in_hurricane_mode) begin
            // 飓风模式
            is_in_hurricane_mode <= 1;
            countdown_time_min <= 1;  // 设置1分钟倒计时
            countdown_time_sec <= 0;
            begin 
                    if (is_in_hurricane_mode) begin
                        if (countdown_time_sec == 0 && countdown_time_min == 0) begin
                            mode_state_fix <= 2;  // 倒计时结束，自动切换到2档
                            is_in_hurricane_mode <= 0;
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
        end
    end


    // 将累计时间转换为time_data格式
    reg [31:0] cumulative_time_data;
    always @(posedge clk) begin
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
    always @(posedge clk) begin
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
    reg display_select;  // 用于选择显示哪个时间（0: 累计时间, 1: 倒计时）
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            display_select <= 0;  // 复位时，默认显示累计时间
        end else if (mode_state == 3'b010 || mode_state == 3'b001) begin
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
