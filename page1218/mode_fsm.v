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
input machine_state,
output reg [2:0]  mode_state,
output reg  menu_btn_state,
output reg [4:0]  led     // led = {self_clean, mode3, mode2, mode1, standby}
);

integer second;
parameter minute = 60;
parameter three_minute = 180;

reg begin_count;
integer time_count;

always @ (posedge clk or negedge rst) begin
    if (~rst) begin
        mode_state <= 3'b000;       // 默认恢复待机状态
        led <= 5'b00001;
        menu_btn_state <= 1'b0;
        begin_count <= 1'b0;
        time_count <= 0;
        second <= 0;

    end else begin
        if (machine_state) begin
            // 设备开启时，按菜单按钮切换风力模式
            
            if (menu_btn) begin
                menu_btn_state <= ~menu_btn_state;
            end

            if (begin_count) begin
                time_count <= time_count + 1;
            end

            if (time_count == 1_00_000_000) begin
                second <= second + 1;
                time_count <= 0;
            end

            if (menu_btn_state & mode_state == 3'b000) begin
                if (mode1_btn) begin
                    mode_state <= 3'b001;
                    led <= 5'b00010;
                    menu_btn_state <= 1'b0;
                    begin_count <= 1'b0;
                    time_count <= 0;
                    second <= 0;
                end
                else if (mode2_btn) begin
                    mode_state <= 3'b010;
                    led <= 5'b00100;
                    menu_btn_state <= 1'b0;
                    begin_count <= 1'b0;
                    time_count <= 0;
                    second <= 0;
                end
                else if (mode3_btn) begin
                    mode_state <= 3'b011;
                    led <= 5'b01000;
                    menu_btn_state <= 1'b0;
                    begin_count <= 1'b0;
                    time_count <= 0;
                    second <= 0;
                    // 没有实现对于 60s 倒计时结束回 2档的操作，现在只写了按菜单键60s后返回待机模式
                end
                else if (mode_self_clean_btn) begin
                    mode_state <= 3'b100;
                    led <= 5'b10000;
                    menu_btn_state <= 1'b0;
                    begin_count <= 1'b1;
                    time_count <= 0;
                    second <= 0;
                end
            end
            else if (~(mode_state == 3'b000))begin
                if (menu_btn_state & (mode_state == 3'b001 | mode_state == 3'b010)) begin
                    mode_state <= 3'b000;
                    led <= 5'b00001;
                    menu_btn_state <= 1'b0;
                    begin_count <= 1'b0;
                    time_count <= 0;
                    second <= 0;
                end else if (mode_state == 3'b001) begin
                    if (mode2_btn) begin
                        mode_state <= 3'b010;
                        led <= 5'b00100;
                        menu_btn_state <= 1'b0;
                        begin_count <= 1'b0;
                        time_count <= 0;
                        second <= 0;
                    end
                end else if (mode_state == 3'b010) begin
                    if (mode1_btn) begin
                        mode_state <= 3'b001;
                        led <= 5'b00010;
                        menu_btn_state <= 1'b0;
                        begin_count <= 1'b0;
                        time_count <= 0;
                        second <= 0;

                    end
                end else if (mode_state == 3'b011) begin
                    if (menu_btn_state) begin
                        begin_count <= 1'b1;
                        time_count <= 0;
                        second <= 0;
                        menu_btn_state <= 1'b0;
                    end

                    if (second == minute) begin
                        mode_state <= 3'b000;
                        led <= 5'b00001;
                        menu_btn_state <= 1'b0;
                        begin_count <= 1'b0;
                        time_count <= 0;
                        second <= 0;

                    end
                end else if (mode_state == 3'b100) begin
                    if (second == three_minute) begin
                        mode_state <= 3'b000;
                        led <= 5'b00001;
                        menu_btn_state <= 1'b0;
                        begin_count <= 1'b0;
                        time_count <= 0;
                        second <= 0;

                    end
                end
            end

            // ###### 设置相关的按钮还没做 
            // 或者另开一个设置module

        end else begin
            mode_state <= 3'b000;
            led <= 5'b00000;
            menu_btn_state <= 1'b0;
            begin_count <= 1'b0;
            time_count <= 0;
            second <= 0;

        end
    end
end

endmodule
