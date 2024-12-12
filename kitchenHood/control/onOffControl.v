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
output reg machine_state = 1'b0
);
parameter shutdown_time = 300_000_000;
integer second_counter;
reg over_shutdown;

parameter gesture_time = 500_000_000;
integer gesture_counter;
reg left_begin;
reg right_begin;
reg left_ges;
reg right_ges;
reg start;

always @ (posedge clk or negedge rst) begin
    if (~rst) begin
        second_counter <= 0;
        machine_state <= 1'b0;
        gesture_counter <= 0;
        left_ges <= 1'b0;
        right_ges <= 1'b0;
        left_begin <= 1'b0;
        right_begin <= 1'b0;
        start <= 1'b0;
    end
    else begin
        if (on_off_btn) begin
            if (~machine_state) begin
                if(~over_shutdown) begin
                    machine_state <= ~machine_state;
                    second_counter <= 0;
                    over_shutdown <= 1'b0;

                    gesture_counter <= 0;
                    left_ges <= 1'b0;
                    right_ges <= 1'b0;
                    left_begin <= 1'b0;
                    right_begin <= 1'b0;
                    start <= 1'b0;
                end
            end
            else begin
                if (second_counter == shutdown_time) begin
                    machine_state <= 1'b0;
                    second_counter <= 0;
                    over_shutdown <= 1'b1;

                    gesture_counter <= 0;
                    left_ges <= 1'b0;
                    right_ges <= 1'b0;
                    left_begin <= 1'b0;
                    right_begin <= 1'b0;
                    start <= 1'b0;
                end
                else begin
                    if (~over_shutdown) begin
                        second_counter <= second_counter + 1;
                    end
                end
            end
        end
        else begin
            second_counter <= 0;
            over_shutdown <= 1'b0;
        end
        
        if (gesture_btn_state) begin
            if (left_btn & ~right_ges & ~left_ges & ~start) begin
                    left_begin <= 1'b1;
                    gesture_counter <= 0;
                    start <= 1'b1;
                    left_ges <= 1'b1;
                end
                if (right_btn & ~left_ges & ~right_ges & ~start) begin
                    right_begin <= 1'b1;
                    gesture_counter <= 0;
                    start <= 1'b1;
                    right_ges <= 1'b1;
                end
                if (left_begin) begin
                    if (gesture_counter < gesture_time) begin
                        gesture_counter <= gesture_counter + 1;
                        if (right_btn) begin
                            gesture_counter <= 0;
                            machine_state <= 1'b1;
                            left_ges <= 1'b0;
                            right_ges <= 1'b0;
                            left_begin <= 1'b0;
                            right_begin <= 1'b0;
                            start <= 1'b0;
                            
                            second_counter <= 0;
                            over_shutdown <= 1'b0;
                        end
                    end else begin
                        gesture_counter <= 0;
                        left_ges <= 1'b0;
                        right_ges <= 1'b0;
                        left_begin <= 1'b0;
                        right_begin <= 1'b0;
                        start <= 1'b0;
                    end
                end
                if (right_begin) begin
                    if (gesture_counter < gesture_time) begin
                        gesture_counter <= gesture_counter + 1;
                        if (left_btn) begin
                            gesture_counter <= 0;
                            machine_state <= 1'b0;
                            left_ges <= 1'b0;
                            right_ges <= 1'b0;
                            left_begin <= 1'b0;
                            right_begin <= 1'b0;
                            start <= 1'b0;
        
                            second_counter <= 0;
                            over_shutdown <= 1'b0;
                        end
                    end else begin
                        gesture_counter <= 0;
                        left_ges <= 1'b0;
                        right_ges <= 1'b0;
                        left_begin <= 1'b0;
                        right_begin <= 1'b0;
                        start <= 1'b0;
                    end
                end
        end
        
    end
end


endmodule