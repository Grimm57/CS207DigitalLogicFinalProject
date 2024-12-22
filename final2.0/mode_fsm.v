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
input return_state,
input show_culmulative_time,
input hurricane_mode_enabled,
output reg [2:0]  mode_state,
output reg  menu_btn_state,
output reg [4:0]  led     // led = {self_clean, mode3, mode2, mode1, standby}
);

reg machine_state_prev;
reg menu_btn_prev;

integer second;
parameter minute = 6;
parameter three_minute = 10;

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

        machine_state_prev <= 1'b0;
        menu_btn_prev <= 1'b0;

    end else begin
        if (machine_state) begin
            // 设备开启时，按菜单按钮切换风力模式
            
            if (menu_btn) begin
                if (menu_btn & ~menu_btn_prev) begin
                    menu_btn_state <= ~menu_btn_state;
                end
            end

            if (begin_count) begin
                time_count <= time_count + 1;
            end

            if (time_count == 100_000_000) begin
                second <= second + 1;
                time_count <= 0;
            end

            if (menu_btn_state & (mode_state == 3'b000)) begin  //为待机状态且按下了菜单键
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
                else if (mode3_btn & hurricane_mode_enabled) begin
                    mode_state <= 3'b011;
                    led <= 5'b01000;
                    menu_btn_state <= 1'b0;
                    begin_count <= 1'b0;
                    time_count <= 0;
                    second <= 0;
                    // 这里只是在初始化三档的倒计时功能，实现在下面(但实际上三挡的倒计时是在smoker中完成，这里并没有用到fsm的倒计时功能)
                end 
                else if (mode_self_clean_btn) begin    
                    mode_state <= 3'b100;
                    led <= 5'b10000;
                    menu_btn_state <= 1'b0;
                    begin_count <= 1'b1;      //一进入自清洁立马开始倒计时180s
                    time_count <= 0;
                    second <= 0;
                end else if(show_culmulative_time) begin
                    mode_state <= 3'b111;

                    menu_btn_state <= 1'b0;
                    begin_count <= 1'b0;
                    time_count <= 0;
                    second <= 0;
                end
            end
            else if (~(mode_state == 3'b000))begin// 不为待机状态时 或者 为待机但没按菜单键（但不会进入下面任何一个if else结构，不执行任何命令） （与上面的if其实是递进关系）
                if (menu_btn_state & (mode_state == 3'b001 | mode_state == 3'b010)) begin //按下菜单键且模式停留在1或2挡
                    mode_state <= 3'b000;
                    led <= 5'b00001;
                    menu_btn_state <= 1'b0;
                    begin_count <= 1'b0;
                    time_count <= 0;
                    second <= 0;
                end else if (mode_state == 3'b001) begin  //1挡时按下2挡变成2挡
                    if (mode2_btn) begin
                        mode_state <= 3'b010;
                        led <= 5'b00100;
                        menu_btn_state <= 1'b0;
                        begin_count <= 1'b0;
                        time_count <= 0;
                        second <= 0;
                    end
                end else if (mode_state == 3'b010) begin  //2挡时按下1挡变成1挡
                    if (mode1_btn) begin
                        mode_state <= 3'b001;
                        led <= 5'b00010;
                        menu_btn_state <= 1'b0;
                        begin_count <= 1'b0;
                        time_count <= 0;
                        second <= 0;

                    end
                end else if (mode_state == 3'b011) begin  //3挡时 按下菜单键 开始倒计时60s
                    // if (menu_btn_state) begin
                    //     begin_count <= 1'b1;
                    //     time_count <= 0;
                    //     second <= 0;
                    //     menu_btn_state <= 1'b0;
                    // end

                    // if (second == minute) begin  //当60s时返回待机状态（这里只是在倒计时，并没有把时间显示出来）
                    //     mode_state <= 3'b000;
                    //     led <= 5'b00001;
                    //     menu_btn_state <= 1'b0;
                    //     begin_count <= 1'b0;
                    //     time_count <= 0;
                    //     second <= 0;
                    // end
                    if(~hurricane_mode_enabled) begin //hurricane_mode_enabled=1时候是可以进入三档，hurricane_mode_enabled=0是不能进入三档
                    if(return_state) begin   //按下了菜单键，return_state=1,回2挡
                        mode_state <= 3'b010;
                        led <= 5'b00100;
                        menu_btn_state <= 1'b0;
                        begin_count <= 1'b0;
                        time_count <= 0;
                        second <= 0;
                    end else begin  //没按菜单键，return_state=0,回待机
                        mode_state <= 3'b000;       
                        led <= 5'b00001;
                        menu_btn_state <= 1'b0;
                        begin_count <= 1'b0;
                        time_count <= 0;
                        second <= 0;
                    end
                    end
                end else if (mode_state == 3'b100) begin  //自清洁时倒计时180s
                    if (second == three_minute) begin   //180s后返回待机状态
                        mode_state <= 3'b000;
                        led <= 5'b00001;
                        menu_btn_state <= 1'b0;
                        begin_count <= 1'b0;
                        time_count <= 0;
                        second <= 0;

                    end
                end else if(mode_state == 3'b111) begin
                    if(menu_btn) begin
                        mode_state <= 3'b000;
                        menu_btn_state <= 1'b0;
                        begin_count <= 1'b0;
                        time_count <= 0;
                        second <= 0;
                    end
                end
            end else begin
                if (~machine_state_prev) begin
                    led <= 5'b00001;
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

        machine_state_prev <= machine_state;
        menu_btn_prev <= menu_btn;

    end
end

endmodule