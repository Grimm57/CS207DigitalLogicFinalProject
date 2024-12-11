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

module mode_fsm(
input clk,
input rst,
input menu_btn,
input mode1_btn,
input mode2_btn,
input mode3_btn,
input mode_self_clean_btn,
output[2:0] mode_state,
output[4:0] led
);

always @ (posedge clk or negedge rst) begin
    if (~rst) begin
        mode_state <= 3'b000;       // 默认恢复待机状态
        led <= 5'b00001;
    end else begin
        if (machine_state) begin
             // 设备开启时，按菜单按钮切换风力模式
            if (menu_btn) begin
                if (mode1_btn) begin
                    mode_state <= 3'b001;
                    led <= 5'b00010;
                end
                else if (mode2_btn) begin
                    mode_state <= 3'b010;
                    led <= 5'b00100;
                end
                else if (mode3_btn) begin
                    mode_state <= 3'b011;
                    led <= 5'b01000;
                end
                else if (mode_self_clean_btn) begin
                    mode_state <= 3'b100;
                    led <= 5'b10000;
                end
                else begin
                    mode_state <= 3'b000;
                    led <= 1'b00001;
                end
                 // ###### 设置相关的按钮还没做 
                 // 或者另开一个设置module
            end
        end else begin
            mode_state <= 3'b000;
            led <= 5'b00000;
        end
    end
end

endmodule