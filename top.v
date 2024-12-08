module top (
    input clk,                    // 时钟信号
    input rst,                    // 复位信号
    input on_off_btn,             // 开关机按钮
    input menu_btn,               // 菜单按钮
    input mode1_btn,              // 1档按钮
    input mode2_btn,              // 2档按钮
    input mode3_btn,              // 3档按钮
    output [7:0] digit1,          // 数码管显示的数字1
    output [7:0] digit2,          // 数码管显示的数字2
    output [7:0] tube_sel,        // 数码管选择信号
    output [4:0] led             // LED信号
);

    // 控制模式状态（待机、1档、2档、3档模式）
    reg [2:0] mode_state;         // 当前模式状态（0: 待机, 1: 1档, 2: 2档, 3: 飓风模式）

    // 控制LED灯的状态
    reg led_menu;

    // 实例化油烟机模块
    smoker smoker_inst (
        .clk(clk),
        .rst(rst),
        .mode_state(mode_state),  // 传递模式状态
        .menu_btn(menu_btn),
        .mode1_btn(mode1_btn),
        .mode2_btn(mode2_btn),
        .mode3_btn(mode3_btn),
        .digit1(digit1),                // 数码管显示的数字1
        .digit2(digit2),                // 数码管显示的数字2
        .tube_sel(tube_sel),          // 数码管选择信号
        .led_mode1(led_mode1),
        .led_mode2(led_mode2),
        .led_mode3(led_mode3)
    );

    // 处理开关机按钮和模式切换
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            mode_state <= 3'b000;  // 默认待机模式
            led_menu <= 0;
        end else begin
            if (on_off_btn) begin
                // 设备开启时，按菜单按钮切换风力模式
                if (menu_btn) begin
                    led_menu <= 1;
                    if (mode1_btn) begin
                        mode_state <= 3'b001;  // 1档模式
                    end else if (mode2_btn) begin
                        mode_state <= 3'b010;  // 2档模式
                    end else if (mode3_btn) begin
                        mode_state <= 3'b011;  // 飓风模式
                    end else begin
                        mode_state <= 3'b000;
                    end
                end else begin
                    led_menu <= 0;  // 菜单按钮没有按下时，菜单LED熄灭
                end
            end else begin
                // 设备关闭时，始终保持待机状态
                mode_state <= 3'b000;
                led_menu <= 0;
            end
        end
    end

    

    // 输出LED信号
    assign led[0] = on_off_btn;          // 第一个LED：表示开机状态（只有开机时会亮）
    assign led[1] = led_menu;            // 第二个LED：表示按下菜单按钮
    assign led[2] = led_mode1;           // 第三个LED：表示按下1档按钮
    assign led[3] = led_mode2;           // 第四个LED：表示按下2档按钮
    assign led[4] = led_mode3;           // 第五个LED：表示按下3档按钮

endmodule
