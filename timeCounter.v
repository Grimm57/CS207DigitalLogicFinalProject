`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/05 08:53:46
// Design Name: 
// Module Name: timeCounter
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