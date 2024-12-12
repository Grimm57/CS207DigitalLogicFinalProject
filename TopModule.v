`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/05 15:22:29
// Design Name: 
// Module Name: TopModule
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
    input clk,
    input rst,
    input menu_btn,
    input mode_self_clean_btn,
    output self_cleaning_indicator,
    output [7:0] digit1,
    output [7:0] digit2,
    output [7:0] tube_sel
);
    // self_cleaning 和 currentTimeTop实例
    wire [7:0] current_digit1, current_digit2, current_tube_sel;
    wire [7:0] clean_digit1, clean_digit2, clean_tube_sel;
    reg [7:0] digit1_reg, digit2_reg, tube_sel_reg;
    
    // 按钮状态变化检测
    reg menu_btn_prev, mode_self_clean_btn_prev;
    wire menu_btn_change, mode_self_clean_btn_change;
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            menu_btn_prev <= 0;
            mode_self_clean_btn_prev <= 0;
        end else begin
            menu_btn_prev <= menu_btn;
            mode_self_clean_btn_prev <= mode_self_clean_btn;
        end
    end
    
    // 按钮变化检测
    assign menu_btn_change = (menu_btn != menu_btn_prev);
    assign mode_self_clean_btn_change = (mode_self_clean_btn != mode_self_clean_btn_prev);
    
    // 当前时间模块和自清洁模块的复位信号
    wire current_time_rst = menu_btn_change;  // 按钮状态变化时复位
    wire self_cleaning_rst = menu_btn & (menu_btn_change | mode_self_clean_btn_change); // 按钮状态变化时复位
    
    // 实例化当前时间模块
    currentTimeTop currentTime (
        .clk(clk),
        .rst(current_time_rst),  // 传递复位信号
        .digit1(current_digit1),
        .digit2(current_digit2),
        .tube_sel(current_tube_sel)
    );
    
    // 实例化自清洁模块
    self_cleaning selfCleaning (
        .clk(clk),
        .rst(self_cleaning_rst),  // 传递复位信号
        .digit1(clean_digit1),
        .digit2(clean_digit2),
        .tube_sel(clean_tube_sel),
        .self_cleaning_indicator(self_cleaning_indicator)
    );

    always @* begin
        // 根据按钮状态选择不同的模块
        if (menu_btn == 1) begin
            if (mode_self_clean_btn == 1) begin
                // 显示自清洁倒计时
                digit1_reg = clean_digit1;
                digit2_reg = clean_digit2;
                tube_sel_reg = clean_tube_sel;
            end else begin
                // 显示当前时间
                digit1_reg = current_digit1;
                digit2_reg = current_digit2;
                tube_sel_reg = current_tube_sel;
            end
        end else begin
            // 如果两个按钮都为0，显示全0
            digit1_reg = 8'b00000000;
            digit2_reg = 8'b00000000;
            tube_sel_reg = 8'b00000000;
        end
    end

    // 输出信号
    assign digit1 = digit1_reg;
    assign digit2 = digit2_reg;
    assign tube_sel = tube_sel_reg;

endmodule



module self_cleaning(
    input clk,
    input rst,
    output [7:0] digit1,
    output [7:0] digit2,
    output [7:0] tube_sel,
    output reg self_cleaning_indicator
);

    reg [5:0] sec = 0;        
    reg [5:0] minute = 3;     
    wire clk_1hz;
    
    ClockDivider1Hz ClockDivider1Hz(
        .clk(clk),
        .rst(rst),
        .clk_out(clk_1hz)
    );
    
    always @(posedge clk_1hz or negedge rst) begin
        if (!rst) begin
            minute <= 3;  // 复位时分钟数重新设置为 3
            sec <= 0;     // 复位时秒数重新设置为 0
        end else if (sec == 0 && minute > 0) begin
            sec <= 59;     // 秒数归零后重置为 59
            minute <= minute - 1; // 分钟数减 1
        end else if (sec > 0) begin
            sec <= sec - 1; // 每秒倒计时减 1
        end
    end

    always @(minute or sec) begin
        if (minute == 0 && sec == 0) begin
            self_cleaning_indicator <= 1;  // 倒计时结束，设置指示器为1
        end else begin
            self_cleaning_indicator <= 0;  // 倒计时未结束，保持指示器为0
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

endmodule


module currentTimeTop(
    input clk,
    input rst,
    output  [7:0]digit1,
    output  [7:0]digit2,
    output  [7:0]tube_sel
    );
    reg [5:0] sec =0;     
    reg [5:0] min =0;     
    reg [4:0] hr =0;     
    wire clk_1hz;
    ClockDivider1Hz ClockDivider1Hz(
            .clk(clk),
            .rst(rst),
            .clk_out(clk_1hz)
    );
    always @(posedge clk_1hz or negedge rst) begin
        if (!rst) begin
            sec <= 6'd0;
            min <= 6'd0;
            hr <= 5'd0;
        end else begin
            if (sec == 59) begin
                sec <= 6'd0;
                if (min == 59) begin
                    min <= 6'd0;
                    if (hr == 23) begin
                        hr <= 5'd0;
                    end else begin
                        hr <= hr + 1;
                    end
                end else begin
                    min <= min + 1;
                end
            end else begin
                sec <= sec + 1;
            end
        end
    end

    reg [31:0] time_data;
    always @(sec or min or hr) begin
        time_data[31:28] = (hr / 10) % 10;    
        time_data[27:24] = hr % 10;           
        time_data[23:20] = 4'b1111;   
        time_data[19:16] = (min / 10) % 10;
        time_data[15:12] = min % 10;   
        time_data[11:8]  = 4'b1111;    
        time_data[7:4]   = (sec / 10) % 10;
        time_data[3:0]   = sec % 10;       
    end
    
    timeDisplay timeDisplay(  .clk(clk),
                .rst(rst),
                .time_data(time_data),
                .digit1(digit1),
                .digit2(digit2),
                .tube_sel(tube_sel)
            );


endmodule

module timeDisplay(
    input   clk,rst,
    input   [31:0]time_data,
    output [7:0]digit1,
    output [7:0]digit2,
    output reg[7:0]tube_sel
);
    wire clk_500hz;
    ClockDivider500Hz ClockDivider500Hz(
            .clk(clk),
            .rst(rst),
            .clk_out(clk_500hz)
    );
    always @(posedge clk_500hz or negedge rst) 
        begin
        if(!rst) tube_sel<=8'b00000001;
        else    tube_sel<={tube_sel[6:0],tube_sel[7]};
        end
    reg[3:0]in_b4;
    always @(tube_sel or time_data) 
        begin
        case(tube_sel)
            8'b00000001:in_b4=time_data[3:0];
            8'b00000010:in_b4=time_data[7:4];
            8'b00000100:in_b4=time_data[11:8];
            8'b00001000:in_b4=time_data[15:12];
            8'b00010000:in_b4=time_data[19:16];
            8'b00100000:in_b4=time_data[23:20];
            8'b01000000:in_b4=time_data[27:24];
            8'b10000000:in_b4=time_data[31:28];
        default:in_b4=4'hf;
        endcase
        end
    transformDigit transformDigit1(
        .in_b4(in_b4),
        .digit(digit1)
    );
    transformDigit transformDigit2(
        .in_b4(in_b4),
        .digit(digit2)
    );
endmodule


module transformDigit(
    input [3:0] in_b4,
    output reg [7:0] digit
);
    always @ (in_b4) begin
        case(in_b4)
            4'b0000: digit = 8'b1111_1100; //"0" : abcdef_ _  
            4'b0001: digit = 8'b0110_0000; //"1":  _bc_ _ _ _ _ _
            4'b0010: digit = 8'b1101_1010; //"2": ab_de_g_ 
            4'b0011: digit = 8'b1111_0010; //"3":  abcd_ _ g _
            4'b0100: digit = 8'b0110_0110; //"4": _bc _ _fg_
            4'b0101: digit = 8'b1011_0110;  //"5": a_cd_fg_
            4'b0110: digit = 8'b1011_1110; //"6": a_cdefg_
            4'b0111: digit = 8'b1110_0000; //"7": abc_ _ _ _ _
            4'b1000: digit = 8'b1111_1110; //"8": abcdefg_
            4'b1001: digit = 8'b1110_0110; //"9": abc_ _ fg_
            default: 
            digit = 8'b0000_0010;  //"E": a_ _ defg_
        endcase
    end
endmodule






module ClockDivider500Hz(
    input clk,    
    input rst,       
    output reg clk_out
);
    parameter period = 200000;
    integer counter;  

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= 0;
            clk_out <= 0; 
        end else begin
            if (counter == ((period >> 1) - 1)) begin  
                clk_out <= ~clk_out;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule


module ClockDivider1Hz(
    input clk,     
    input rst,        
    output reg clk_out
);
    parameter period = 100_000_000;
    integer counter;  

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= 0;
            clk_out <= 0;  
        end else begin
            if (counter == ((period >> 1) - 1)) begin  
                clk_out <= ~clk_out;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule