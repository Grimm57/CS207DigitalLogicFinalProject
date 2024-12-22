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


module onOffControl(
input clk,
input rst,
input left_btn,
input right_btn,
input on_off_btn,
input gesture_btn_state,
output reg machine_state = 1'b0,

output [7:0] digit1,         // 数字管显示 1
output [7:0] digit2,         // 数字管显示 2
output [7:0] tube_sel       // 显示管选择
);
parameter shutdown_time = 300_000_000;
integer counter;
reg over_change;
reg over_gesture;

// parameter gesture_time = 500_000_000;
parameter second = 100_000_000;
reg [5:0] gesture = 6'd5;

integer gesture_counter;
integer second_counter;
reg left_begin;
reg right_begin;
reg left_ges;
reg right_ges;
reg start;

always @ (posedge clk) begin
    if (~rst) begin
        counter <= 0;
        machine_state <= 1'b0;
        gesture_counter <= 0;
        second_counter <= 0;
        left_ges <= 1'b0;
        right_ges <= 1'b0;
        left_begin <= 1'b0;
        right_begin <= 1'b0;
        start <= 1'b0;

        over_change <= 1'b0;

        //
        gesture <= 6'd5;
    end
    else begin
        if (on_off_btn) begin
            if (~machine_state) begin
                if(~over_change) begin
                    machine_state <= ~machine_state;
                    counter <= 0;
                    over_change <= 1'b1;
                    second_counter <= 0;
                    gesture_counter <= 0;
                    left_ges <= 1'b0;
                    right_ges <= 1'b0;
                    left_begin <= 1'b0;
                    right_begin <= 1'b0;
                    start <= 1'b0;
                end
            end
            else begin
                if (counter == shutdown_time) begin
                    machine_state <= 1'b0;
                    counter <= 0;
                    over_change <= 1'b1;
                    second_counter <= 0;
                    gesture_counter <= 0;
                    left_ges <= 1'b0;
                    right_ges <= 1'b0;
                    left_begin <= 1'b0;
                    right_begin <= 1'b0;
                    start <= 1'b0;
                end
                else begin
                    if (~over_change) begin
                        counter <= counter + 1;
                    end
                end
            end
        end
        else begin
            counter <= 0;
            over_change <= 1'b0;
        end
    end

    if (gesture_btn_state) begin
        if (left_btn & ~right_ges & ~left_ges & ~start) begin
            if (~over_gesture) begin
                left_begin <= 1'b1;
                gesture_counter <= 0;
                second_counter <= 0;
                start <= 1'b1;
                left_ges <= 1'b1;
            end
        end
        if (right_btn & ~left_ges & ~right_ges & ~start) begin
            if (~over_gesture) begin
                right_begin <= 1'b1;
                gesture_counter <= 0;
                second_counter <= 0;
                start <= 1'b1;
                right_ges <= 1'b1;
            end
        end
        if (~left_btn & ~right_btn) begin
            over_gesture <= 1'b0;
        end

        if (left_begin) begin
            if (gesture_counter < gesture) begin
                second_counter <= second_counter + 1;
                if (second_counter == second) begin
                    gesture_counter <= gesture_counter + 1;
                    second_counter <= 0;
                end
                if (right_btn) begin
                    gesture_counter <= 0;
                    second_counter <= 0;
                    machine_state <= 1'b1;
                    left_ges <= 1'b0;
                    right_ges <= 1'b0;
                    left_begin <= 1'b0;
                    right_begin <= 1'b0;
                    start <= 1'b0;
                            
                    counter <= 0;
                    over_gesture <= 1'b1;
                end 
            end else begin
                gesture_counter <= 0;
                second_counter <= 0;
                left_ges <= 1'b0;
                right_ges <= 1'b0;
                left_begin <= 1'b0;
                right_begin <= 1'b0;
                start <= 1'b0;

                over_gesture <= 1'b0;
            end
        end
        if (right_begin) begin
            if (gesture_counter < gesture) begin
                second_counter <= second_counter + 1;
                if (second_counter == second) begin
                    gesture_counter <= gesture_counter + 1;
                    second_counter <= 0;
                end
                if (left_btn) begin
                    gesture_counter <= 0;
                    second_counter <= 0;
                    machine_state <= 1'b0;
                    left_ges <= 1'b0;
                    right_ges <= 1'b0;
                    left_begin <= 1'b0;
                    right_begin <= 1'b0;
                    start <= 1'b0;
        
                    counter <= 0;
                    over_gesture <= 1'b1;
                end 
            end else begin
                gesture_counter <= 0;
                second_counter <= 0;
                left_ges <= 1'b0;
                right_ges <= 1'b0;
                left_begin <= 1'b0;
                right_begin <= 1'b0;
                start <= 1'b0;

                over_gesture <= 1'b0;
            end
        end
    end
end

// 将手势有效秒数放进 time_data
reg [31:0] time_data;
always @(gesture) begin
    time_data[11:8] = 4'b1111;
    time_data[23:20] = 4'b1111;
    time_data[7:4]  = (gesture / 10) % 10;     // 秒钟十位
    time_data[3:0]  = gesture % 10;            // 秒钟个位
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


endmodule