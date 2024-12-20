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
