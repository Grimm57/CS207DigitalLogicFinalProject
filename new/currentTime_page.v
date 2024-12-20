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
    output [7:0] digit1,         // 数字管显示 1
    output [7:0] digit2,         // 数字管显示 2
    output [7:0] tube_sel,       // 显示管选择
    output reg time_adjust_led,  // 时间调整 LED 指示
    output reg [5:0] location_led
    );

    // 定义按钮编码
    parameter UP = 4'b0001;    // 按钮 1
    parameter LEFT = 4'b0010;  // 按钮 2
    parameter RIGHT = 4'b0100; // 按钮 3
    parameter DOWN = 4'b1000;  // 按钮 4

    reg [5:0] sec = 0;      // 秒
    reg [5:0] min = 0;      // 分钟
    reg [4:0] hr = 0;       // 小时

    integer counter;     // 系统时钟计数器，用于生成秒级时钟

    reg [3:0] key_vc;
    reg [3:0] key_vp;
    reg [19:0] keycnt;

    always @(posedge clk or negedge rst) begin
        if(!rst)
            begin
                keycnt <= 0;
                key_vc <= 4'd0;
            end
        else
            begin
            if(keycnt>=20'd999_999)
                begin
                keycnt <= 0;
                key_vc <= btn;
                end
            else    keycnt<=keycnt+20'd1;
            end
    end

    always @(posedge clk) begin
        key_vp <= key_vc;
    end

    wire [3:0]key_rise_edge;
    assign key_rise_edge = (~key_vp[3:0])&key_vc[3:0];

    // 时间调节模式
    reg time_adjust_mode;
    
    reg [5:0] location = 5'b000001;

    // 系统时钟计数器，模拟1秒钟计数
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            counter <= 0;
            sec <= 6'd0;
            min <= 6'd0;
            hr <= 5'd0;
        end else begin
            if (key_rise_edge == DOWN) begin  // 按下 DOWN 按钮，切换时间调整模式
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
                case(key_rise_edge)
                    UP: begin location[5:0]={location[4:0],location[5]};   end

                    RIGHT: 
                        case(location)
                            6'b000001:begin if(sec   >=59)begin sec=0;         if(min>=59)begin min=0;hr=0;end else min=min+1;end else sec = sec  +1;    end
                            6'b000010:begin if(sec/10>=5) begin sec=sec%10;if(min>=59)begin min=0;hr=0;end else min=min+1;end else sec = sec  +10;   end
                            6'b000100:begin if(min   >=59)begin min=0;         if(hr>=23)hr=0;    else hr=hr+1;    end else min = min  +1;    end
                            6'b001000:begin if(min/10>=5) begin min=min%10;if(hr>=23)hr=0;    else hr=hr+1;    end else min = min  +10;   end
                            6'b010000:begin if(hr     >=23)begin hr=0;                                    end else hr   = hr    +1;    end
                            6'b100000:begin if(hr/10  >=2) begin hr=hr%10;end else begin hr   = hr  +10; if(hr>23)hr=23; end   end
                        endcase  
                    LEFT:  
                        case(location) 
                            6'b000001:begin if(sec   ==0)begin sec=59;           if(min==0)begin min=59;hr=23;end else min=min-1;end else sec = sec  -1;    end
                            6'b000010:begin if(sec/10==0)begin sec=sec%10+50;if(min==0)begin min=59;hr=23;end else min=min-1;end else sec = sec  -10;   end
                            6'b000100:begin if(min   ==0)begin min=59;           if(hr==0)hr=23;    else hr=hr-1;    end else min = min  -1;    end
                            6'b001000:begin if(min/10==0)begin min=min%10+50;if(hr==0)hr=23;    else hr=hr-1;    end else min = min  -10;   end
                            6'b010000:begin if(hr     ==0)begin hr=23;                               end else hr   = hr    -1;    end
                            6'b100000:begin if(hr/10  ==0)begin hr=hr%10+20;                      end else hr   = hr    -10;   end
                        endcase

                endcase

            end else begin
                counter <= counter + 1;
            end
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
