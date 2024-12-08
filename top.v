module top (
    input clk,                    // ʱ���ź�
    input rst,                    // ��λ�ź�
    input on_off_btn,             // ���ػ���ť
    input menu_btn,               // �˵���ť
    input mode1_btn,              // 1����ť
    input mode2_btn,              // 2����ť
    input mode3_btn,              // 3����ť
    output [7:0] digit1,          // �������ʾ������1
    output [7:0] digit2,          // �������ʾ������2
    output [7:0] tube_sel,        // �����ѡ���ź�
    output [4:0] led             // LED�ź�
);

    // ����ģʽ״̬��������1����2����3��ģʽ��
    reg [2:0] mode_state;         // ��ǰģʽ״̬��0: ����, 1: 1��, 2: 2��, 3: 쫷�ģʽ��

    // ����LED�Ƶ�״̬
    reg led_menu;

    // ʵ�������̻�ģ��
    smoker smoker_inst (
        .clk(clk),
        .rst(rst),
        .mode_state(mode_state),  // ����ģʽ״̬
        .menu_btn(menu_btn),
        .mode1_btn(mode1_btn),
        .mode2_btn(mode2_btn),
        .mode3_btn(mode3_btn),
        .digit1(digit1),                // �������ʾ������1
        .digit2(digit2),                // �������ʾ������2
        .tube_sel(tube_sel),          // �����ѡ���ź�
        .led_mode1(led_mode1),
        .led_mode2(led_mode2),
        .led_mode3(led_mode3)
    );

    // �����ػ���ť��ģʽ�л�
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            mode_state <= 3'b000;  // Ĭ�ϴ���ģʽ
            led_menu <= 0;
        end else begin
            if (on_off_btn) begin
                // �豸����ʱ�����˵���ť�л�����ģʽ
                if (menu_btn) begin
                    led_menu <= 1;
                    if (mode1_btn) begin
                        mode_state <= 3'b001;  // 1��ģʽ
                    end else if (mode2_btn) begin
                        mode_state <= 3'b010;  // 2��ģʽ
                    end else if (mode3_btn) begin
                        mode_state <= 3'b011;  // 쫷�ģʽ
                    end else begin
                        mode_state <= 3'b000;
                    end
                end else begin
                    led_menu <= 0;  // �˵���ťû�а���ʱ���˵�LEDϨ��
                end
            end else begin
                // �豸�ر�ʱ��ʼ�ձ��ִ���״̬
                mode_state <= 3'b000;
                led_menu <= 0;
            end
        end
    end

    

    // ���LED�ź�
    assign led[0] = on_off_btn;          // ��һ��LED����ʾ����״̬��ֻ�п���ʱ������
    assign led[1] = led_menu;            // �ڶ���LED����ʾ���²˵���ť
    assign led[2] = led_mode1;           // ������LED����ʾ����1����ť
    assign led[3] = led_mode2;           // ���ĸ�LED����ʾ����2����ť
    assign led[4] = led_mode3;           // �����LED����ʾ����3����ť

endmodule
