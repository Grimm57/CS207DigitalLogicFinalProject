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
input on_off_btn,
input menu_btn,
input mode1_btn,
input mode2_btn,
input mode3_btn,
input mode_self_clean_btn,
output[5:0] current_time,
output[5:0] cumulative_time,
output[2:0] count_down_time
    );
    wire machine_state;
    wire[2:0] mode_state;// 0���� 000    1һ�� 001  2���� 010 3���� 011 4����� 100
    
    // ʵ��FSM����mode_stateת��
    // ʵ������ʱmodule
    // ʵ����������ʾ��module
    
    //�ڼ�ʱģ���к���ʾģ���У���Ҫ����mode_state�����������ƣ�ƥ����Щ�ɽ��еĲ���
endmodule
