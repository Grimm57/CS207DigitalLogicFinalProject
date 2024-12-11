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