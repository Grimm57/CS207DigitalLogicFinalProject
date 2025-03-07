`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/04 00:38:15
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
input clk,
input reset,
input left_btn,
input right_btn,
input on_off_btn,
input menu_btn,
input mode1_btn,
input mode2_btn,
input mode3_btn,
input mode_self_clean_btn,
input gesture_btn_state,
output machine_state
//output[2:0] mode_state// 0待机 000    1一档 001  2二档 010 3三档 011 4自清洁 100
    );
    wire clk_1hz;
    // 实现FSM进行mode_state转换
    // 实例化计时module
    // 实例化数码显示管module
    //在计时模块中和显示模块中，都要根据mode_state进行条件控制，匹配哪些可进行的操作
    //    ClockDivider1Hz clk_1s(
    //    .clk(clk),
    //    .rst(reset),
    //    .clk_out(clk_1hz));
    ClockDivider1Hz clock1hzzzz(.clk(clk),.rst(reset),.clk_out(clk_1hz));
    
    onOffControl on_off_control(
    .clk(clk),
    .reset(reset),
    .left_btn(left_btn),
    .right_btn(right_btn),
    .on_off_btn(on_off_btn),
    .gesture_btn_state(gesture_btn_state),
    .machine_state(machine_state));
    

    
endmodule

module onOffControl(
input clk,
input reset,
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

always @ (posedge clk or negedge reset) begin
    if (~reset) begin
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

module timeCounterTop(
    input clk,
    input rst,
    output  [7:0]digit1,
    output  [7:0]digit2,
    output  [7:0]tube_sel
    );
    reg [5:0] sec =0;     
    reg [5:0] min =0;     
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
        end else begin
            if (sec == 59) begin
                sec <= 6'd0;
                if (min == 59) begin
                    min <= 6'd0;
                end else begin
                    min <= min + 1;
                end
            end else begin
                sec <= sec + 1;  
            end
        end
    end

    reg [31:0] time_data;
    always @(sec or min) begin
        time_data[31:28] = 4'b0000;
        time_data[27:24] = 4'b0000;
        time_data[23:20] = 4'b0000;
        time_data[19:16] = 4'b0000;
        time_data[15:12] = (min)%10;
        time_data[11:8]  = 4'b0000;
        time_data[7:4]   = (sec)/10;
        time_data[3:0]   = (sec)%10;
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
            digit = 8'b1001_1110;  //"E": a_ _ defg_
        endcase
    end
endmodule






module ClockDivider500Hz(
    input clk,    
    input rst,       
    output reg clk_out
);
    parameter period = 100000;
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