module smoker (
    input clk,                    // ԭʼʱ���źţ�����500Hz��
    input rst,                    // ��λ�ź�
    input [2:0] mode_state,       // ��ǰ����ģʽ���루0��������1��1����2��2����3��3����
    input menu_btn,               // �˵���ť
    input mode1_btn,              // 1����ť
    input mode2_btn,              // 2����ť
    input mode3_btn,              // 3����ť
    output [7:0] digit1,          // �������ʾ������1
    output [7:0] digit2,          // �������ʾ������2
    output [7:0] tube_sel,        // �����ѡ���ź�
    output reg led_mode1, led_mode2, led_mode3
);

  wire clk_1hz;
    ClockDivider1Hz u_clk_divider (
        .clk(clk),
        .rst(rst),
        .clk_out(clk_1hz)   // ��� 1Hz ʱ��
    );
    
    // ���Ʒ���ģʽ
    reg [2:0] wind_mode;           // ��ǰ������λ��0: ������1: 1����2: 2����3: 3����쫷�ģʽ��
    reg is_in_hurricane_mode;      // �Ƿ���쫷�ģʽ��
    reg hurricane_mode_enabled;    // 쫷�ģʽ�Ƿ����ã�ֻ��ʹ��һ�Σ�
    

    // ��ʱ�ź�
    reg [5:0] cumulative_time_min; // �ۼƷ���
    reg [5:0] cumulative_time_sec; // �ۼ�����
    reg [5:0] countdown_time_min;  // ����ʱ����
    reg [5:0] countdown_time_sec;  // ����ʱ����

    // ���Ʒ���ģʽ
    always @(posedge clk_1hz or negedge rst) begin
        if (!rst) begin
            wind_mode <= 0;  // Ĭ�ϴ���ģʽ
            cumulative_time_sec <= 0;
            cumulative_time_min <= 0;
            countdown_time_sec <= 0;
            countdown_time_min <= 1;
            is_in_hurricane_mode <= 0;
            hurricane_mode_enabled <= 1;
            led_mode1 <= 0;
            led_mode2 <= 0;
            led_mode3 <= 0;
        end else begin
            if (mode_state == 3'b000) begin
            // ����ģʽ
            wind_mode <= 0;
            led_mode1 <=0;
            led_mode2 <=0;
            led_mode3 <=0;
        end else if (mode_state == 3'b001) begin
            // 1������
            wind_mode <= 1;
            led_mode1 <=1;
        end else if (mode_state == 3'b010) begin
            // 2������
            wind_mode <= 2;
            led_mode2 <=1;
        end else if (mode_state == 3'b011 && hurricane_mode_enabled && !is_in_hurricane_mode) begin
            // 쫷�ģʽ
            wind_mode <= 3;
            is_in_hurricane_mode <= 1;
            countdown_time_min <= 1;  // ����1���ӵ���ʱ
            countdown_time_sec <= 0;
            led_mode3 <=1;
        end

            case (wind_mode)
                3'b000: begin // ����ģʽ
                    led_mode1 <= 0;
                    led_mode2 <= 0;
                    led_mode3 <= 0;
                end
                3'b001: begin // 1������ģʽ
                    if (cumulative_time_sec == 59) begin
                        cumulative_time_sec <= 0;
                        if (cumulative_time_min == 59) begin
                            cumulative_time_min <= 0;
                        end else begin
                            cumulative_time_min <= cumulative_time_min + 1;
                        end
                    end else begin
                        cumulative_time_sec <= cumulative_time_sec + 1;
                    end
                end
                3'b010: begin // 2������ģʽ
                    if (cumulative_time_sec == 59) begin
                        cumulative_time_sec <= 0;
                        if (cumulative_time_min == 59) begin
                            cumulative_time_min <= 0;
                        end else begin
                            cumulative_time_min <= cumulative_time_min + 1;
                        end
                    end else begin
                        cumulative_time_sec <= cumulative_time_sec + 1;
                    end
                end
                3'b011: begin // 쫷�ģʽ
                    if (is_in_hurricane_mode) begin
                        if (countdown_time_sec == 0 && countdown_time_min == 0) begin
                            wind_mode <= 2;  // ����ʱ�������Զ��л���2��
                            is_in_hurricane_mode <= 0;
                            hurricane_mode_enabled <= 0;  // ֻ��ʹ��һ��
                            led_mode3 <=0;
                            led_mode2 <=1;
                        end else if (countdown_time_sec == 0) begin
                            if (countdown_time_min > 0) begin
                                countdown_time_min <= countdown_time_min - 1;
                                countdown_time_sec <= 59;
                            end
                        end else begin
                            countdown_time_sec <= countdown_time_sec - 1;
                        end
                    end
                end
            endcase
        end
    end


    // ���ۼ�ʱ��ת��Ϊtime_data��ʽ
    reg [31:0] cumulative_time_data;
    always @(posedge clk_1hz) begin
        cumulative_time_data[31:28] = 4'b0000;           // ʱ��������Ϊ 0
        cumulative_time_data[27:24] = 4'b0000;           // ʱ��������Ϊ 0
        cumulative_time_data[23:20] = 4'b1111;           // �ָ���
        cumulative_time_data[19:16] = cumulative_time_min / 10;       // ���ӵ�ʮλ��
        cumulative_time_data[15:12] = cumulative_time_min % 10;       // ���ӵĸ�λ��
        cumulative_time_data[11:8]  = 4'b1111;           // �ָ���
        cumulative_time_data[7:4]   = cumulative_time_sec / 10;          // ���ʮλ��
        cumulative_time_data[3:0]   = cumulative_time_sec % 10;          // ��ĸ�λ��
    end

    // ������ʱת��Ϊtime_data��ʽ
    reg [31:0] countdown_time_data;
    always @(posedge clk_1hz) begin
        countdown_time_data[31:28] = 4'b0000;           // ʱ��������Ϊ 0
        countdown_time_data[27:24] = 4'b0000;           // ʱ��������Ϊ 0
        countdown_time_data[23:20] = 4'b1111;           // �ָ���
        countdown_time_data[19:16] = countdown_time_min / 10;       // ���ӵ�ʮλ��
        countdown_time_data[15:12] = countdown_time_min % 10;       // ���ӵĸ�λ��
        countdown_time_data[11:8]  = 4'b1111;           // �ָ���
        countdown_time_data[7:4]   = countdown_time_sec / 10;          // ���ʮλ��
        countdown_time_data[3:0]   = countdown_time_sec % 10;          // ��ĸ�λ��
    end

    // ������ʾ�л�
    reg display_select;  // ����ѡ����ʾ�ĸ�ʱ�䣨0: �ۼ�ʱ��, 1: ����ʱ��
    always @(posedge clk_1hz or negedge rst) begin
        if (!rst) begin
            display_select <= 0;  // ��λʱ��Ĭ����ʾ�ۼ�ʱ��
        end else if (wind_mode == 3'b010 || wind_mode == 3'b001) begin
            display_select <= 0;  // ��ʾ�ۼ�ʱ��
        end else if (wind_mode == 3'b011) begin
            display_select <= 1;  // ��쫷�ģʽ����ʾ����ʱ
        end
    end


    // ������ʾѡ�������Ӧ��ʱ������
    reg [31:0] display_data;
    always @(display_select)begin
        if(display_select)begin
            display_data=countdown_time_data;
        end else begin
            display_data=cumulative_time_data;
        end
    end
    

    // ʵ����timeDisplayģ��
    timeDisplay u_time_display (
        .clk(clk),   
        .rst(rst),
        .time_data(display_data),
        .digit1(digit1),
        .digit2(digit2),
        .tube_sel(tube_sel)
    );

    


endmodule
