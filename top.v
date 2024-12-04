module top (
    input clk,                // 时钟信号
    input rst_n,              // 复位信号
    input on_off_btn,         // 开关机按钮
    input menu_btn,           // 菜单按钮
    input mode1_btn,          // 1档按钮
    input mode2_btn,          // 2档按钮
    input mode3_btn,          // 3档按钮
    output [5:0] cumulative_time,  // 累计工作时间（时:分:秒）
    output [5:0] countdown_time     // 飓风模式倒计时
);

    // 状态定义
    reg [2:0] mode_state;  // 当前模式状态（待机、1档、2档、3档）

    // 实例化油烟机模块
    smoker smoker_inst (
        .clk(clk),
        .rst_n(rst_n),
        .mode_state(mode_state),
        .menu_btn(menu_btn),
        .mode1_btn(mode1_btn),
        .mode2_btn(mode2_btn),
        .mode3_btn(mode3_btn),
        .cumulative_time(cumulative_time),
        .countdown_time(countdown_time)
    );

    // 控制模式状态：待机、1档、2档、3档（通过按钮控制）
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mode_state <= 3'b000;  // 默认待机模式
        end else if (menu_btn) begin
            // 菜单键按下后根据按键切换不同模式
            if (mode1_btn) begin
                mode_state <= 3'b001;  // 1档模式
            end else if (mode2_btn) begin
                mode_state <= 3'b010;  // 2档模式
            end else if (mode3_btn) begin
                mode_state <= 3'b011;  // 飓风模式
            end
        end else if (mode_state != 3'b000) begin
            // 返回待机模式
            mode_state <= 3'b000;
        end
    end

endmodule
