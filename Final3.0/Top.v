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


module top(
input clk,                    // ʱ���ź�
input rst,                    // ��λ�ź�

input adjust_choose_sw,         //�޸Ĳ���ѡ��


input pageneg1_btn,              // 1: �߼�����
input page0_btn,              // 1: ����࣬���ػ����˵�
input page1_btn,              // 1: �л���һ����������
input page2_btn,              // 1: �л���ʱ�������ذ���
input page3_btn,              // 1: �߼�������ذ���
input page4_btn,              // 1: �л������ư���

output machine_state,          // ����״̬
output menu_btn_state,          // ����״̬

input up_btn,                 // �ϰ�ť
input left_btn,               // ��ť
input middle_btn,             // �а�ť
input right_btn,              // �Ұ�ť
input down_btn,               // �°�ť
input handClean,              //�ֶ������

input light_sw,
output light_led,

output [7:0] digit1,          // �������ʾ������1
output [7:0] digit2,          // �������ʾ������2
output [7:0] tube_sel,        // �����ѡ���ź�
output meun_btn_pressed,
output [4:0] led,              // LED�ź�
output needClean,
output return_state
    );
    wire clk_1hz;             // 1Hz ʱ���ź�

    wire on_off_btn;
    assign on_off_btn = middle_btn;

    wire menu_btn;
    assign menu_btn = (page1_btn|page0_btn|page3_btn) & up_btn;
    wire mode1_btn;
    assign mode1_btn = page1_btn & left_btn;
    wire mode2_btn;
    assign mode2_btn = page1_btn & right_btn;

    wire mode3_btn;
    assign mode3_btn = page1_btn & down_btn;
    
    wire mode_self_clean_btn;
    assign mode_self_clean_btn = page0_btn & down_btn;

    wire show_culmulative_time;
    assign show_culmulative_time= page0_btn & left_btn;

    wire show_gesture_time;
    assign show_gesture_time = page0_btn & right_btn;

    wire show_anouncement_time;
    assign show_anouncement_time = page3_btn & left_btn;
    

    wire gesture_left;
    assign gesture_left = page4_btn & left_btn;
    wire gesture_right;
    assign gesture_right = page4_btn & right_btn;
    
    wire [3:0] time_adjust_btn;
    assign time_adjust_btn = {page2_btn & down_btn,page2_btn & right_btn,page2_btn & left_btn,page2_btn & up_btn};

    wire [3:0] anoucnemnt_time_adjust_btn;
    assign anoucnemnt_time_adjust_btn = {~adjust_choose_sw & pageneg1_btn & down_btn,~adjust_choose_sw &pageneg1_btn & right_btn,~adjust_choose_sw &pageneg1_btn & left_btn,~adjust_choose_sw &pageneg1_btn & up_btn};


    wire [3:0] gesture_adjust_btn;
    assign gesture_adjust_btn = {adjust_choose_sw & pageneg1_btn & down_btn,adjust_choose_sw & pageneg1_btn & right_btn,adjust_choose_sw & pageneg1_btn & left_btn,adjust_choose_sw & pageneg1_btn & up_btn};

    reg [7:0] digit1_out_top;         // �������ʾ������1
    reg [7:0] digit2_out_top;         // �������ʾ������1
    reg [7:0] tube_sel_out_top;         // �������ʾ������1

    wire [7:0] digit1_out_smoker;         // �������ʾ������1
    wire [7:0] digit2_out_smoker;         // �������ʾ������1
    wire [7:0] tube_sel_out_smoker;         // �������ʾ������1

    wire [7:0] digit1_out_selfClean;         // �������ʾ������1
    wire [7:0] digit2_out_selfClean;         // �������ʾ������1
    wire [7:0] tube_sel_out_selfClean;         // �������ʾ������1

    wire [7:0] digit1_out_time;         // �������ʾ������1
    wire [7:0] digit2_out_time;         // �������ʾ������1
    wire [7:0] tube_sel_out_time;         // �������ʾ������1

    wire [7:0] digit1_out_gesture;         // �������ʾ������1
    wire [7:0] digit2_out_gesture;         // �������ʾ������1
    wire [7:0] tube_sel_out_gesture;         // �������ʾ������1

    wire clearTime;

    //ʵ����1Hz��Ƶ��
    ClockDivider1Hz clock1hzzzz(.clk(clk),.rst(rst),.clk_out(clk_1hz));
    
    //ʵ�������ػ�ģ��
    onOffControl on_off_control(
    .clk(clk),
    .rst(rst),
    .btn(gesture_adjust_btn),
    .left_btn(gesture_left),
    .right_btn(gesture_right),
    .on_off_btn(on_off_btn),
    .gesture_btn_state(page4_btn),
    .machine_state(machine_state),

    .digit1(digit1_out_gesture),
    .digit2(digit2_out_gesture),
    .tube_sel(tube_sel_out_gesture)
    );

    wire [2:0] mode_state;      // ģʽ״̬ 000���� 001һ�� 010���� 011������쫷磩 100�����
    wire hurricane_mode_enabled;
    
    // ״̬����
    parameter STANDBY        = 3'b000;
    parameter MODE1          = 3'b001;
    parameter MODE2          = 3'b010;
    parameter MODE3          = 3'b011;
    parameter SELF_CLEAN     = 3'b100;
    parameter show_Gesture_time = 3'b110;
    parameter show_Anouncement_time = 3'b101;
    parameter show_Culmulative_time = 3'b111;


    //ʵ�������̻�ģ��
    smoker smoker_inst (
        .clk(clk),
        .rst(rst),
        .btn(anoucnemnt_time_adjust_btn),
        .mode_state(mode_state),                    // ����ģʽ״̬
        .menu_btn(menu_btn),
        .digit1(digit1_out_smoker),                // �������ʾ������1
        .digit2(digit2_out_smoker),                // �������ʾ������2
        .tube_sel(tube_sel_out_smoker),
        .return_state(return_state),
        .hurricane_mode_enabled(hurricane_mode_enabled),
        .meun_btn_pressed(meun_btn_pressed),
        .needClean(needClean),
        .handClean(handClean),
        .machine_state(machine_state),
        .clearTime(clearTime)
    );
    

    //ʵ����ģʽѡ��ģ��
    mode_fsm mode_fsm_inst (
        .clk(clk),
        .rst(rst),
        .menu_btn(menu_btn),
        .mode1_btn(mode1_btn),
        .mode2_btn(mode2_btn),
        .mode3_btn(mode3_btn),
        .mode_self_clean_btn(mode_self_clean_btn),
        .machine_state(machine_state),
        .mode_state(mode_state),
        .menu_btn_state(menu_btn_state),
        .led(led),
        .return_state(return_state),
        .show_culmulative_time(show_culmulative_time),
        .show_gesture_time(show_gesture_time),
        .show_anouncement_time(show_anouncement_time),
        .hurricane_mode_enabled(hurricane_mode_enabled)
    );

    wire [5:0] location_led;
    //��ǰʱ����ʾģ��
    currentTime u_currentTime (
    .clk(clk),                     // ����ϵͳʱ��
    .rst(rst),                     // ���Ӹ�λ�ź�
    .btn(time_adjust_btn),                     // ���Ӱ�ť����
    .digit1(digit1_out_time),               // �������ֹ���ʾ 1
    .digit2(digit2_out_time),               // �������ֹ���ʾ 2
    .tube_sel(tube_sel_out_time),           // ������ʾ��ѡ��
    .time_adjust_led(time_adjust_led),  // ����ʱ����� LED ָʾ
    .location_led(location_led),    // ����λ�� LED
    .middle_btn(middle_btn),
    .machine_state(machine_state)
    );
    
    //�����ģ��
    selfcleaner selfcleaner (
    .clk(clk),                     // ����ϵͳʱ��
    .rst(rst),                     // ���Ӹ�λ�ź�
    .mode_state(mode_state),
    .digit1(digit1_out_selfClean),               // �������ֹ���ʾ 1
    .digit2(digit1_out_selfClean),               // �������ֹ���ʾ 2
    .tube_sel(tube_sel_out_selfClean),           // ������ʾ��ѡ��
    .clear_accumulated_time(clearTime)
    );

    light light_inst(
    .clk(clk),
    .rst(rst),
    .machine_state(machine_state),
    .light_sw(light_sw),
    .light_led(light_led)
    );

    
    always @(posedge clk) begin
        if (machine_state)begin
            case(mode_state)
                STANDBY:begin digit1_out_top = digit1_out_time;
                              digit2_out_top = digit2_out_time;
                              tube_sel_out_top = tube_sel_out_time;  
                        end
                
                SELF_CLEAN:begin digit1_out_top = digit1_out_selfClean;
                                 digit2_out_top = digit2_out_selfClean;
                                tube_sel_out_top = tube_sel_out_selfClean;  
                            end
                
                
                MODE1: begin
                    digit1_out_top = digit1_out_time;
                    digit2_out_top = digit2_out_time;
                    tube_sel_out_top = tube_sel_out_time;  
                end

                MODE2: begin
                    digit1_out_top = digit1_out_time;
                    digit2_out_top = digit2_out_time;
                    tube_sel_out_top = tube_sel_out_time;  
                end

                show_Culmulative_time:begin
                    digit1_out_top = digit1_out_smoker;
                    digit2_out_top = digit1_out_smoker;
                    tube_sel_out_top = tube_sel_out_smoker;  
                end

                show_Gesture_time: begin
                    digit1_out_top = digit1_out_gesture;
                    digit2_out_top = digit1_out_gesture;
                    tube_sel_out_top = tube_sel_out_gesture;
                end
                
                show_Anouncement_time: begin
                    digit1_out_top = digit1_out_smoker;
                    digit2_out_top = digit1_out_smoker;
                    tube_sel_out_top = tube_sel_out_smoker;
                end

                MODE3:begin
                            digit1_out_top = digit1_out_smoker;
                            digit2_out_top =digit1_out_smoker;
                            tube_sel_out_top = tube_sel_out_smoker;  
                end

                default:begin digit1_out_top = digit1_out_time;
                              digit2_out_top =digit2_out_time;
                              tube_sel_out_top = tube_sel_out_time;  
                        end
            endcase
        end else begin
            digit1_out_top = 8'b00000000;
            digit2_out_top = 8'b00000000;
            tube_sel_out_top = 8'b00000000;
        end
    end
    
    assign digit1 = digit1_out_top;
    assign digit2 = digit2_out_top;
    assign tube_sel = tube_sel_out_top;    
endmodule