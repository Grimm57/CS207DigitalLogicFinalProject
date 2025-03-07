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

module smoker (
    input clk,                    // 原始时钟信号（例如500Hz）
    input rst,                    // 复位信号
    input [2:0] mode_state,       // 当前工作模式输入（0：待机，1：1档，2：2档，3：3档）
    input menu_btn,               //用于按下菜单键60s关闭三档
    input handClean,
    input [3:0] btn,             // 2 位二进制编码的按钮输入
    input machine_state,
    input clearTime,
    output [7:0] digit1,          // 数码管显示的数字1
    output [7:0] digit2,          // 数码管显示的数字2
    output [7:0] tube_sel,        // 数码管选择信号
    output reg return_state,      //输出三档结束后要变回的状态
    output reg hurricane_mode_enabled,    // 飓风模式是否可以启用（只能使用一次）
    output reg needClean,
    output reg meun_btn_pressed //用来看是否在三档时按下了菜单键
);

    reg machine_state_prev;


    // 定义四个按钮的编码
    parameter UP = 4'b0001;    // 按钮 1
    parameter LEFT = 4'b0010;  // 按钮 2
    parameter RIGHT = 4'b0100; // 按钮 3
    parameter DOWN = 4'b1000;  // 按钮 4


    wire clk_1hz;
    ClockDivider1Hz u_clk_divider (
        .clk(clk),
        .rst(rst),
        .clk_out(clk_1hz)   // 输出 1Hz 时钟
    );


    reg [3:0] btn_current;//表示当前的按钮状态
    reg [3:0] btn_prev;//表示上一个按钮状态
    
    reg [19:0] constantCount;

    always @(posedge clk or negedge rst) begin
        if(!rst)
            begin
                constantCount <= 0;
                btn_current <= 4'd0;
            end
        else
            begin
            if(constantCount>=20'd999_999)
                begin
                constantCount <= 0;
                btn_current <= btn;
                end
            else    constantCount<=constantCount+20'd1;
            end
    end

    always @(posedge clk) begin
        btn_prev <= btn_current;
    end

    wire [3:0]btn_rise_edge;
    assign btn_rise_edge = (~btn_prev[3:0])&btn_current[3:0];

    // 计时信号
    reg [5:10] cumulative_time_hour; //累计小时
    reg [5:0] cumulative_time_min; // 累计分钟
    reg [5:0] cumulative_time_sec; // 累计秒数
    reg [5:0] countdown_time_min;  // 倒计时分钟
    reg [5:0] countdown_time_sec;  // 倒计时秒数
    reg prev_clearTime;
    reg prev_clearTime_temp;
    reg prev_1;
    reg prev_2;
    integer counter;


  // 控制风力模式
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cumulative_time_hour <=0;
            cumulative_time_sec <= 0;
            cumulative_time_min <= 0;
            prev_clearTime <=0;
            counter <=0;
        end else if(handClean)begin
            cumulative_time_hour <=0;
            cumulative_time_sec <= 0;
            cumulative_time_min <= 0;
            counter <=0;
        end else if(prev_clearTime != clearTime)begin
            cumulative_time_hour <=0;
            cumulative_time_sec <= 0;
            cumulative_time_min <= 0;
            counter <=0;
            prev_clearTime <=clearTime;
        end else begin
            if (mode_state == 3'b001 | mode_state == 3'b010 | mode_state == 3'b011) begin
            // 1档风力
                if(counter == 99_999_999) begin
                    counter <= 0;
                    if (cumulative_time_sec == 59) begin
                        cumulative_time_sec <= 0;  // 重置秒数
                        if (cumulative_time_min == 59) begin
                            cumulative_time_min <= 0;  // 重置分钟
                            if (cumulative_time_hour == 23) begin
                                cumulative_time_hour <= 0;  // 重置小时
                            end else begin
                                cumulative_time_hour <= cumulative_time_hour + 1;  // 累加小时
                            end
                        end else begin
                            cumulative_time_min <= cumulative_time_min + 1;  // 累加分钟
                        end
                    end else begin
                    cumulative_time_sec <= cumulative_time_sec + 1;  // 累加秒数
                    end

                end else begin
                    counter <= counter + 1;
                end
            end
        end
    end


    reg resetCountdown;
    reg once;
    integer c;
    reg [5:0] down;

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            meun_btn_pressed <=0;
            resetCountdown <=0;
            down <=0;
            c<=0;
            prev_2 <=0;
        end else begin
            if(handClean)begin
                down <=0;
                c<=0;
            end else if(prev_2!=clearTime)begin
                down <=0;
                c<=0;
                prev_2<=clearTime;
            end else begin
                if(mode_state==3'b011 & hurricane_mode_enabled) begin
                    if(menu_btn)begin
                        meun_btn_pressed <=1;
                        resetCountdown <=1;
                    end
                    if(c==99_999_999)begin
                        c<=0;          
                        if(~meun_btn_pressed)begin down<=down + 1; end
                    end else begin
                    c <= c+1;
                    end
                end
            end

            if (machine_state) begin
                if (~machine_state_prev) begin
                    meun_btn_pressed <= 0;
                end
            end
        end
    end
    integer cnt;

    always @(posedge clk or negedge rst) begin
        if(~rst)begin
            countdown_time_sec <= 0;
            countdown_time_min <= 1;
            hurricane_mode_enabled <= 1;
            once <= 1;
            prev_clearTime_temp <=0;
            cnt <=0;
        end else begin
            if(resetCountdown & once) begin
                countdown_time_sec <= 0;
                countdown_time_min <= 1;
                once <=0;
                cnt <=0;
            end else if(handClean) begin
                cnt <=0;
            end else if(prev_clearTime_temp != clearTime)begin
                cnt <=0;
                prev_clearTime_temp <= clearTime;
            end else begin
                if (mode_state == 3'b011 & hurricane_mode_enabled) begin
                    if(cnt == 99_999_999) begin
                        cnt <= 0;
                        if (countdown_time_sec == 0 & countdown_time_min == 0) begin  //倒计时结束，返回某个状态
                            if(meun_btn_pressed)begin
                            //回到待机
                                return_state <=0;
                            end else begin
                            //回到二挡
                                return_state <=1;
                            end
                            hurricane_mode_enabled <= 0;  // 只能使用一次
                        end else if (countdown_time_sec == 0) begin
                            if (countdown_time_min > 0) begin
                                countdown_time_min <= countdown_time_min - 1;
                                countdown_time_sec <= 59;
                            end
                        end else begin
                            countdown_time_sec <= countdown_time_sec - 1;
                        end        
                    end else begin
                    cnt <= cnt + 1;
                    end       
                end
            end  

            if (machine_state) begin
                if (~machine_state_prev) begin
                    countdown_time_sec <= 0;
                    countdown_time_min <= 1;
                    hurricane_mode_enabled <= 1;
                    once <= 1;
                    prev_clearTime_temp <=0;
                    cnt <=0;
                end
            end  
        end
    end

    reg [5:0] anouncement_sec = 0;
    reg [5:0] anouncement_min = 0;
    reg [4:0] anouncement_hr = 10;

    //调整智能提醒时间
    reg time_adjust_mode = 0;

    reg [5:0] location = 5'b000001;

    // 系统时钟计数器，模拟1秒钟计数
    always @(posedge clk) begin
        if (!rst) begin
            anouncement_sec <= 0;
            anouncement_min <= 0;
            anouncement_hr <= 10;
            time_adjust_mode <=0;
        end else begin
            if (btn_rise_edge == DOWN & machine_state) begin  // 按下 DOWN 按钮，切换到时间调整模式
                time_adjust_mode <= ~time_adjust_mode;
            end

            if (time_adjust_mode) begin
                case(btn_rise_edge)
            // 按下上按钮之后把目前要修改的位置往左边移动一位
            UP: begin
                location[5:0] = {location[4:0], location[5]};   
            end

            RIGHT: begin//使用right 按钮来增加时间
                // 选择要修改哪一位的时间
                case(location)
                    //这一位对应的是秒数个位
                    6'b000001: begin
                        if(anouncement_sec >= 59) begin
                            anouncement_sec = 0;         
                            //如果秒数计时到了60，那么就把分钟数加一
                            if(anouncement_min >= 59) begin
                                anouncement_min = 0;
                                anouncement_hr = 0;
                            end else begin
                                anouncement_min = anouncement_min + 1;
                            end
                            //如果秒数没有到60的话，就把秒数加一
                            //每检测到一个上升沿就把秒数加一
                        end else begin
                            anouncement_sec = anouncement_sec + 1;
                        end
                    end

                    //这一位对应的是秒数的十位
                    6'b000010: begin
                        if(anouncement_sec / 10 >= 5) begin
                            anouncement_sec = anouncement_sec % 10;
                            //如果秒数的十位超过了五的话就把秒数赋值为现在秒数的个位，然后更新分钟
                            if(anouncement_min >= 59) begin 
                                anouncement_min = 0;
                                anouncement_hr = 0;
                            end else begin 
                                anouncement_min = anouncement_min + 1;
                            end
                        end else begin
                            //每次检测到这个按钮的上升沿就把秒数增加十
                            anouncement_sec = anouncement_sec + 10;
                        end
                    end
                    //这一位对应了分钟
                    6'b000100: begin
                        if(anouncement_min >= 59) begin
                            anouncement_min = 0;
                            if(anouncement_hr >= 23) begin 
                                anouncement_hr = 0;
                            end else begin
                                anouncement_hr = anouncement_hr + 1;    
                            end
                        end else begin
                            anouncement_min = anouncement_min + 1;
                        end
                    end

                    6'b001000: begin
                        if(anouncement_min / 10 >= 5) begin 
                            anouncement_min = anouncement_min % 10;
                            if(anouncement_hr >= 23) 
                                anouncement_hr = 0;
                            else 
                                anouncement_hr = anouncement_hr + 1; 
                        end else begin
                            anouncement_min = anouncement_min + 10;
                        end
                    end

                    6'b010000: begin
                        if(anouncement_hr >= 23) begin
                            anouncement_hr = 0;
                        end else begin
                            anouncement_hr = anouncement_hr + 1;
                        end
                    end

                    6'b100000: begin
                        if(anouncement_hr / 10 >= 2) begin 
                            anouncement_hr = anouncement_hr % 10;
                        end else begin 
                            anouncement_hr = anouncement_hr + 10;
                            if(anouncement_hr > 23)
                                anouncement_hr = 23;
                        end
                    end
                endcase  
            end

            LEFT: begin
                case(location) 
                    6'b000001: begin
                        if(anouncement_sec == 0) begin
                            anouncement_sec = 59;           
                            if(anouncement_min == 0) begin
                                anouncement_min = 59;
                                anouncement_hr = 23;
                            end else begin
                                anouncement_min = anouncement_min - 1;
                            end
                        end else begin
                            anouncement_sec = anouncement_sec - 1;
                        end
                    end

                    6'b000010: begin
                        if(anouncement_sec / 10 == 0) begin
                            anouncement_sec = anouncement_sec % 10 + 50;
                            if(anouncement_min == 0) begin
                                anouncement_min = 59;
                                anouncement_hr = 23;
                            end else begin
                                anouncement_min = anouncement_min - 1;
                            end
                        end else begin
                            anouncement_sec = anouncement_sec - 10;
                        end
                    end

                    6'b000100: begin
                        if(anouncement_min == 0) begin
                            anouncement_min = 59;           
                            if(anouncement_hr == 0)
                                anouncement_hr = 23;
                            else 
                                anouncement_hr = anouncement_hr - 1;    
                        end else begin
                            anouncement_min = anouncement_min - 1;
                        end
                    end

                    6'b001000: begin
                        if(anouncement_min / 10 == 0) begin
                            anouncement_min = anouncement_min % 10 + 50;
                            if(anouncement_hr == 0)
                                anouncement_hr = 23;
                            else 
                                anouncement_hr = anouncement_hr - 1;
                        end else begin
                            anouncement_min = anouncement_min - 10;
                        end
                    end

                    6'b010000: begin
                        if(anouncement_hr == 0) begin
                            anouncement_hr = 23;                              
                        end else begin
                            anouncement_hr = anouncement_hr - 1;
                        end
                    end

                    6'b100000: begin
                        if(anouncement_hr / 10 == 0) begin
                            anouncement_hr = anouncement_hr % 10 + 20;                      
                        end else begin
                            anouncement_hr = anouncement_hr - 10;
                        end
                    end
                endcase
            end
        endcase
            end 
            if (machine_state) begin
                if (~machine_state_prev) begin
                // anouncement_sec <= 6'd0;
                // anouncement_min <= 6'd0;
                // anouncement_hr <= 5'd10;
                end
            end

            machine_state_prev <= machine_state;
        end

    end


    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            needClean<=0;
        end else begin
            //------------------------------------------------------------------------------------------------------------------------------------------------------------------
        if(
            (cumulative_time_sec + cumulative_time_hour*3600 + cumulative_time_min*60 >= anouncement_sec + anouncement_min* 60 + anouncement_hr*3600)
            & machine_state
        )begin  
        //------------------------------------------------------------------------------------------------------------------------------------------------------------------------
            needClean <=1;
        end else begin
            needClean <=0;
        end
        end
    end

    reg [5:0] min;
    reg [6:0] sec;
    reg mode3_finish;
        always @(posedge clk or negedge rst)           
            begin                                        
                if(!rst)begin
                    min<=0;
                    sec<=0;
                    prev_1 <= 0;
                    mode3_finish<=0;
                end else if(handClean) begin
                    min<=0;
                    sec<=0;
                    mode3_finish<=1;
                end else if(prev_1 != clearTime)begin
                    min<=0;
                    sec<=0;
                    mode3_finish<=1;
                    prev_1 <= clearTime;
                end                              
                else begin
                    min <= ((~hurricane_mode_enabled & ~mode3_finish) ? cumulative_time_min+1 : cumulative_time_min);
                    sec <= (meun_btn_pressed ? cumulative_time_sec+down : cumulative_time_sec);
                    if(sec >=60)begin
                        sec <= sec-60;
                        min <=min+1;
                    end
                end                                     
            end           

    // 将智能提醒时间转换为time_data格式
    reg [31:0] anouncement_time_data;
    always @(posedge clk) begin
        anouncement_time_data[31:28] = anouncement_hr / 10;           // 时部分设置为 0
        anouncement_time_data[27:24] = anouncement_hr % 10;           // 时部分设置为 0
        anouncement_time_data[23:20] = 4'b1111;           // 分隔符
        anouncement_time_data[19:16] = anouncement_min / 10;       // 分钟的十位数
        anouncement_time_data[15:12] = anouncement_min % 10;       // 分钟的个位数
        anouncement_time_data[11:8]  = 4'b1111;           // 分隔符
        anouncement_time_data[7:4]   = anouncement_sec / 10;          // 秒的十位数
        anouncement_time_data[3:0]   = anouncement_sec % 10;          // 秒的个位数
    end
    
    // 将累计时间转换为time_data格式
    reg [31:0] cumulative_time_data;
    always @(posedge clk) begin
        cumulative_time_data[31:28] = cumulative_time_hour / 10;           // 时部分设置为 0
        cumulative_time_data[27:24] = cumulative_time_hour % 10;           // 时部分设置为 0
        cumulative_time_data[23:20] = 4'b1111;           // 分隔符
        cumulative_time_data[19:16] = cumulative_time_min / 10;       // 分钟的十位数
        cumulative_time_data[15:12] = cumulative_time_min % 10;       // 分钟的个位数
        cumulative_time_data[11:8]  = 4'b1111;           // 分隔符
        cumulative_time_data[7:4]   = cumulative_time_sec / 10;          // 秒的十位数
        cumulative_time_data[3:0]   = cumulative_time_sec % 10;          // 秒的个位数
    end

    // 将倒计时转换为time_data格式
    reg [31:0] countdown_time_data;
    always @(posedge clk) begin
        countdown_time_data[31:28] = 4'b0000;           // 时部分设置为 0
        countdown_time_data[27:24] = 4'b0000;           // 时部分设置为 0
        countdown_time_data[23:20] = 4'b1111;           // 分隔符
        countdown_time_data[19:16] = countdown_time_min / 10;       // 分钟的十位数
        countdown_time_data[15:12] = countdown_time_min % 10;       // 分钟的个位数
        countdown_time_data[11:8]  = 4'b1111;           // 分隔符
        countdown_time_data[7:4]   = countdown_time_sec / 10;          // 秒的十位数
        countdown_time_data[3:0]   = countdown_time_sec % 10;          // 秒的个位数
    end

    // 控制显示切换
    reg[1:0] display_select =2'b00;  // 用于选择显示哪个时间（0: 累计时间, 1: 倒计时）
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            display_select <= 2'b00;  // 复位时，默认显示累计时间
        end else if (mode_state == 3'b010 | mode_state == 3'b001) begin
            display_select <= 2'b00;  // 显示累计时间
        end else if (mode_state == 3'b011) begin
            display_select <= 2'b01;  // 在飓风模式下显示倒计时
        end else if (mode_state == 3'b101) begin
            display_select <= 2'b10; //在显示智能提醒时间模式显示智能提醒时间
        end
    end


    // 根据显示选择输出相应的时间数据
    reg [31:0] display_data;
    
    always @(display_select)begin
        if(display_select == 2'b01)begin
            display_data=countdown_time_data;
        end else if (display_select ==2'b00) begin
            display_data=cumulative_time_data;
        end else if (display_select ==2'b10) begin
            display_data=anouncement_time_data;
        end
    end
    

    // 实例化timeDisplay模块
    timeDisplay u_time_display (
        .clk(clk),   
        .rst(rst),
        .time_data(display_data),
        .digit1(digit1),
        .digit2(digit2),
        .tube_sel(tube_sel)
    );

    


endmodule