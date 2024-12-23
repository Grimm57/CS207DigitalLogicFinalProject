`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/17 09:05:26
// Design Name: 
// Module Name: current_time_display
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

module currentTime(
    input clk,                   // 系统时钟
    input rst,                   // 重置信号
    input [3:0] btn,             // 2 位二进制编码的按钮输入

    input middle_btn,
    input machine_state,
    
    output [7:0] digit1,         // 数字管显示 1
    output [7:0] digit2,         // 数字管显示 2
    output [7:0] tube_sel,       // 显示管选择
    output reg time_adjust_led,  // 时间调整 LED 指示
    output reg [5:0] location_led
    );

    reg machine_state_prev;


    // 定义四个按钮的编码
    parameter UP = 4'b0001;    // 按钮 1
    parameter LEFT = 4'b0010;  // 按钮 2
    parameter RIGHT = 4'b0100; // 按钮 3
    parameter DOWN = 4'b1000;  // 按钮 4

    reg [5:0] sec = 0;      // 秒
    reg [5:0] min = 0;      // 分钟
    reg [4:0] hr = 0;       // 小时

    integer counter;     // 系统时钟计数器，用于生成秒级时钟

    reg [3:0] btn_current;//表示当前的按钮状态
    reg [3:0] btn_prev;//表示上一个按钮状态
    
    reg [19:0] constantCount;

    always @(posedge clk or negedge rst) begin
        if(!rst)
            begin
                constantCount <= 0;
                btn_current <= 4'd0;
            end
        else
            begin
            if(constantCount>=20'd999_999)
                begin
                constantCount <= 0;
                btn_current <= btn;
                end
            else    constantCount<=constantCount+20'd1;
            end
    end

    always @(posedge clk) begin
        btn_prev <= btn_current;
    end

    wire [3:0]btn_rise_edge;
    assign btn_rise_edge = (~btn_prev[3:0])&btn_current[3:0];

    // 时间调节模式
    reg time_adjust_mode;
    
    reg [5:0] location = 5'b000001;

    // 系统时钟计数器，模拟1秒钟计数
    always @(posedge clk) begin
        if (!rst) begin
            counter <= 0;
            sec <= 6'd0;
            min <= 6'd0;
            hr <= 5'd0;
        end else begin
            if (btn_rise_edge == DOWN & machine_state) begin  // 按下 DOWN 按钮，切换到时间调整模式
                time_adjust_mode <= ~time_adjust_mode;
            end

            if(!time_adjust_mode && counter >= 100_000_000) begin
                    counter <= 0;

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
            end else if (time_adjust_mode) begin
                case(btn_rise_edge)
            // 按下上按钮之后把目前要修改的位置往左边移动一位
            UP: begin
                location[5:0] = {location[4:0], location[5]};   
            end

            RIGHT: begin//使用right 按钮来增加时间
                // 选择要修改哪一位的时间
                case(location)
                    //这一位对应的是秒数个位
                    6'b000001: begin
                        if(sec >= 59) begin
                            sec = 0;         
                            //如果秒数计时到了60，那么就把分钟数加一
                            if(min >= 59) begin
                                min = 0;
                                hr = 0;
                            end else begin
                                min = min + 1;
                            end
                            //如果秒数没有到60的话，就把秒数加一
                            //每检测到一个上升沿就把秒数加一
                        end else begin
                            sec = sec + 1;
                        end
                    end

                    //这一位对应的是秒数的十位
                    6'b000010: begin
                        if(sec / 10 >= 5) begin
                            sec = sec % 10;
                            //如果秒数的十位超过了五的话就把秒数赋值为现在秒数的个位，然后更新分钟
                            if(min >= 59) begin 
                                min = 0;
                                hr = 0;
                            end else begin 
                                min = min + 1;
                            end
                        end else begin
                            //每次检测到这个按钮的上升沿就把秒数增加十
                            sec = sec + 10;
                        end
                    end
                    //这一位对应了分钟
                    6'b000100: begin
                        if(min >= 59) begin
                            min = 0;
                            if(hr >= 23) begin 
                                hr = 0;
                            end else begin
                                hr = hr + 1;    
                            end
                        end else begin
                            min = min + 1;
                        end
                    end

                    6'b001000: begin
                        if(min / 10 >= 5) begin 
                            min = min % 10;
                            if(hr >= 23) 
                                hr = 0;
                            else 
                                hr = hr + 1; 
                        end else begin
                            min = min + 10;
                        end
                    end

                    6'b010000: begin
                        if(hr >= 23) begin
                            hr = 0;
                        end else begin
                            hr = hr + 1;
                        end
                    end

                    6'b100000: begin
                        if(hr / 10 >= 2) begin 
                            hr = hr % 10;
                        end else begin 
                            hr = hr + 10;
                            if(hr > 23)
                                hr = 23;
                        end
                    end
                endcase  
            end

            LEFT: begin
                case(location) 
                    6'b000001: begin
                        if(sec == 0) begin
                            sec = 59;           
                            if(min == 0) begin
                                min = 59;
                                hr = 23;
                            end else begin
                                min = min - 1;
                            end
                        end else begin
                            sec = sec - 1;
                        end
                    end

                    6'b000010: begin
                        if(sec / 10 == 0) begin
                            sec = sec % 10 + 50;
                            if(min == 0) begin
                                min = 59;
                                hr = 23;
                            end else begin
                                min = min - 1;
                            end
                        end else begin
                            sec = sec - 10;
                        end
                    end

                    6'b000100: begin
                        if(min == 0) begin
                            min = 59;           
                            if(hr == 0)
                                hr = 23;
                            else 
                                hr = hr - 1;    
                        end else begin
                            min = min - 1;
                        end
                    end

                    6'b001000: begin
                        if(min / 10 == 0) begin
                            min = min % 10 + 50;
                            if(hr == 0)
                                hr = 23;
                            else 
                                hr = hr - 1;
                        end else begin
                            min = min - 10;
                        end
                    end

                    6'b010000: begin
                        if(hr == 0) begin
                            hr = 23;                              
                        end else begin
                            hr = hr - 1;
                        end
                    end

                    6'b100000: begin
                        if(hr / 10 == 0) begin
                            hr = hr % 10 + 20;                      
                        end else begin
                            hr = hr - 10;
                        end
                    end
                endcase
            end
        endcase
            end else begin
                counter <= counter + 1;
            end

            if (machine_state) begin
                if (~machine_state_prev) begin
                counter <= 0;
                sec <= 6'd0;
                min <= 6'd0;
                hr <= 5'd0;
                end
            end

            machine_state_prev <= machine_state;
        end

    end

    // 将时、分、秒组合成 32 位的 time_data
    reg [31:0] time_data;
    always @(sec or min or hr) begin
        time_data[31:28] = (hr / 10) % 10;      // 小时十位
        time_data[27:24] = hr % 10;             // 小时个位
        time_data[23:20] = 4'b1111;             // 分隔符
        time_data[19:16] = (min / 10) % 10;     // 分钟十位
        time_data[15:12] = min % 10;            // 分钟个位
        time_data[11:8]  = 4'b1111;             // 分隔符
        time_data[7:4]   = (sec / 10) % 10;     // 秒钟十位
        time_data[3:0]   = sec % 10;            // 秒钟个位
    end

    // 时间显示模块
    timeDisplay timeDisplay(
        .clk(clk),
        .rst(rst),
        .time_data(time_data),
        .digit1(digit1),
        .digit2(digit2),
        .tube_sel(tube_sel)
    );

    // 时间调整 LED 指示
    always @(posedge clk) begin
        if (time_adjust_mode) 
            time_adjust_led <= 1;
        else
            time_adjust_led <= 0;
    end
    always @* begin
        location_led = location;
    end

endmodule