`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/25 10:53:01
// Design Name: 
// Module Name: CountDown
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

module TopModule (
    input clk_in,      // 输入时钟 (100 MHz)
    input rst,         // 复位信号
    output [6:0] seg_minute_tens,   // 分钟十位七段数码管
    output [6:0] seg_minute_ones,   // 分钟个位七段数码管
    output [6:0] seg_second_tens,   // 秒钟十位七段数码管
    output [6:0] seg_second_ones,   // 秒钟个位七段数码管
    output countdown_done        // 倒计时完成信号
);
    wire clk_1Hz;  // 1 Hz 时钟信号，用于倒计时器

    // 实例化时钟分频器模块
    ClockDivider u_ClockDivider (
        .clk_in(clk_in),
        .rst(rst),
        .clk_out(clk_1Hz)
    );

    // 实例化倒计时器模块
    CountdownTimer u_CountdownTimer (
        .clk_1Hz(clk_1Hz),
        .rst(rst),
        .seg_minute_tens(seg_minute_tens),
        .seg_minute_ones(seg_minute_ones),
        .seg_second_tens(seg_second_tens),
        .seg_second_ones(seg_second_ones),
        .countdown_done(countdown_done)
    );
endmodule

//
module ClockDivider (
    input clk_in,     // 输入时钟 (100 MHz)
    input rst,        // 复位信号
    output reg clk_out // 输出时钟 (1 Hz)
);
    parameter period = 100_000_000;
    reg [29:0] counter;  // 30位计数器，用于计数100 MHz时钟周期

    always @(posedge clk_in, negedge rst) begin
        if (!rst) begin
            counter <= 30'd0;
            clk_out <= 0;  // 复位时，输出时钟为0
        end else begin
            if (counter == ((period>>1)-1)) begin  // 当计数器达到100,000,000时（100 MHz的100,000,000周期，1秒）
                clk_out <= ~clk_out;  // 翻转输出时钟信号
                counter <= 30'd0;     // 计数器清零
            end else begin
                counter <= counter + 1;  // 计数器递增
            end
        end
    end
endmodule

module CountdownTimer (
    input clk_flow_light,
    input clk_1Hz,           // 1 Hz 输入时钟信号
    input rst,               // 复位信号
    output reg [7:0] seg_minute_tens,   // 分钟十位七段数码管
    output reg [7:0] seg_minute_ones,   // 分钟个位七段数码管
    output reg [7:0] seg_second_tens,   // 秒钟十位七段数码管
    output reg [7:0] seg_second_ones,   // 秒钟个位七段数码管
    output reg countdown_done      // 倒计时完成信号
);
    reg [7:0] countdown_counter;  // 倒计时计数器（最大 255）
    wire [6:0] minute_tens_seg, minute_ones_seg, second_tens_seg, second_ones_seg;

    // 分钟和秒数的十位和个位
    reg [3:0] minute_tens, minute_ones, second_tens, second_ones;

    // 通过七段解码器来显示数字
    SevenSegmentDecoder u_minute_tens_decoder (
        .digit(minute_tens), 
        .seg(minute_tens_seg)
    );
    
    SevenSegmentDecoder u_minute_ones_decoder (
        .digit(minute_ones), 
        .seg(minute_ones_seg)
    );
    
    SevenSegmentDecoder u_second_tens_decoder (
        .digit(second_tens), 
        .seg(second_tens_seg)
    );
    
    SevenSegmentDecoder u_second_ones_decoder (
        .digit(second_ones), 
        .seg(second_ones_seg)
    );

    // 更新七段显示信号
    always @(posedge clk_1Hz or negedge rst) begin
        if (!rst) begin
            countdown_counter <= 180;  // 初始值为 180 秒
            minute_tens <= 0;          // 分钟十位清零
            minute_ones <= 3;          // 分钟个位初始化为 3
            second_tens <= 0;          // 秒钟十位清零
            second_ones <= 0;          // 秒钟个位清零
            countdown_done <= 0;       // 倒计时未完成
        end else begin
            if (countdown_counter > 0) begin
                countdown_counter <= countdown_counter - 1;  // 倒计时递减

                // 计算分钟和秒数
                minute_tens <= countdown_counter / 60;        // 分钟十位
                minute_ones <= countdown_counter / 60 % 10;   // 分钟个位
                second_tens <= countdown_counter % 60 / 10;   // 秒钟十位
                second_ones <= countdown_counter % 60 % 10;   // 秒钟个位
                
                countdown_done <= 0;  // 倒计时未完成
            end else begin
                countdown_done <= 1;  // 倒计时完成
            end
        end
    end

    // 输出七段数码管编码
    always @(*) begin
        seg_minute_tens = minute_tens_seg;
        seg_minute_ones = minute_ones_seg;
        seg_second_tens = second_tens_seg;
        seg_second_ones = second_ones_seg;
    end
endmodule



module SevenSegmentDecoder (
    input [3:0] digit,      // 输入 4 位数字
    output reg [7:0] seg    // 输出七段数码管编码（abcdefg）
);
    always @(*) begin
        case (digit)
            4'b0000: seg = 8'b1111_1100; //"0" : abcdef_ _  
            4'b0001: seg = 8'b0110_0000; //"1":  _bc_ _ _ _ _ _
            4'b0010: seg = 8'b1101_1010; //"2": ab_de_g_ 
            4'b0011: seg = 8'b1111_0010; //"3":  abcd_ _ g _
            4'b0100: seg = 8'b0110_0110; //"4": _bc _ _fg_
            4'b0101: seg = 8'b1011_0110;  //"5": a_cd_fg_
            4'b0110: seg = 8'b1011_1110; //"6": a_cdefg_
            4'b0111: seg = 8'b1110_0000; //"7": abc_ _ _ _ _
            4'b1000: seg = 8'b1111_1110; //"8": abcdefg_
            4'b1001: seg = 8'b1110_0110; //"9": abc_ _ fg_
            default: seg = 8'b0000_0000; // 默认关闭所有段
        endcase
    end
endmodule

module BreathingLight(
    input clk,
    output light
);

endmodule