module smoker (
    input clk,                    // 时钟信号
    input rst_n,                  // 复位信号
    input [2:0] mode_state,       // 当前工作模式输入（0：待机，1：1档，2：2档，3：3档）
    input menu_btn,               // 菜单按钮
    input mode1_btn,              // 1档按钮
    input mode2_btn,              // 2档按钮
    input mode3_btn,              // 3档按钮
    output reg [5:0] cumulative_time, // 累计工作时间
    output reg [5:0] countdown_time  // 飓风模式倒计时
);

    // 状态定义
    reg [5:0] timer;              // 定时器，用于累积计时
    reg [2:0] wind_mode;          // 当前风力档位，0: 未开始，1: 1档，2: 2档，3: 3档（飓风模式）
    reg is_in_hurricane_mode;     // 是否在飓风模式中
    reg hurricane_mode_enabled;   // 飓风模式是否启用（只能使用一次）

    // 初始状态
    initial begin
        cumulative_time = 0;
        timer = 0;
        wind_mode = 0;
        is_in_hurricane_mode = 0;
        hurricane_mode_enabled = 1; // 开机后第一次可以使用飓风模式
    end

    // 控制累积时间和倒计时
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cumulative_time <= 0;
            timer <= 0;
            wind_mode <= 0;
            is_in_hurricane_mode <= 0;
            hurricane_mode_enabled <= 1; // 重置后重新启用飓风模式
        end else begin
            // 根据风力模式开始计时
            if (wind_mode == 1 || wind_mode == 2 || wind_mode == 3) begin
                cumulative_time <= cumulative_time + 1;
            end

            // 飓风模式倒计时
            if (is_in_hurricane_mode) begin
                if (countdown_time > 0) begin
                    countdown_time <= countdown_time - 1;
                end else begin
                    // 倒计时结束，自动切换到二级档位
                    wind_mode <= 2; 
                    is_in_hurricane_mode <= 0;
                    countdown_time <= 0;
                end
            end
        end
    end

    // 模式控制逻辑：根据按键控制不同的风力模式
    always @(posedge clk) begin
        if (mode_state == 0) begin
            // 待机模式下，等待用户操作
            if (menu_btn) begin
                // 菜单按钮按下，进入模式切换
                if (mode1_btn) begin
                    wind_mode <= 1;  // 1档
                end else if (mode2_btn) begin
                    wind_mode <= 2;  // 2档
                end else if (mode3_btn && hurricane_mode_enabled) begin
                    wind_mode <= 3;  // 飓风模式
                    is_in_hurricane_mode <= 1;
                    countdown_time <= 60; // 启动飓风模式倒计时
                    hurricane_mode_enabled <= 0; // 只能使用一次
                end
            end
        end else if (mode_state != 0) begin
            // 如果当前模式不为待机，进行其他操作
            if (mode_state == 1) begin
                // 1档风力
                wind_mode <= 1;
            end else if (mode_state == 2) begin
                // 2档风力
                wind_mode <= 2;
            end else if (mode_state == 3 && hurricane_mode_enabled) begin
                // 飓风模式
                wind_mode <= 3;
                is_in_hurricane_mode <= 1;
                countdown_time <= 60; // 启动飓风模式倒计时
                hurricane_mode_enabled <= 0; // 只能使用一次
            end
        end
    end

endmodule
