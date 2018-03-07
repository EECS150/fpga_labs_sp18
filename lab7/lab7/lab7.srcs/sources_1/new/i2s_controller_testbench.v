`timescale 1ns/100ps

`define SECOND 1000000000
`define MS 1000000
`define SYSTEM_CLK_PERIOD 8
`define BIT_DEPTH 24

module i2s_controller_testbench();
    // System clock domain I/O
    reg system_clock = 0;
    reg system_reset = 0;
    //reg square_wave = 0;
    //reg [3:0] volume_control = 0;

    // Connections between AC97 codec and controller
    //wire sdata_out, sync, reset_b, bit_clk;
    
    wire mclk, sclk, lrck, sdin;

    // Generate system clock
    always #(`SYSTEM_CLK_PERIOD/2) system_clock = ~system_clock;

    reg [`BIT_DEPTH-1:0] pcm_data;
    reg  left_valid, right_valid;
    wire left_ready, right_ready;

    i2s_controller #(
      .SYS_CLOCK_FREQ(125_000_000),
      .LRCK_FREQ_HZ(88_200),
      .MCLK_TO_LRCK_RATIO(128)
    ) i2s (
      .sys_reset(system_reset),
      .sys_clk(system_clock),
      .pcm_data(pcm_data),
      .pcm_data_valid({left_valid, right_valid}),
      .pcm_data_ready({left_ready, right_ready}),
      .mclk(mclk),
      .sclk(sclk),
      .lrck(lrck),
      .sdin(sdin)
    );

    initial begin
        pcm_data = 0;
        // Pulse the system reset to the i2s controller
        @(posedge system_clock);
        system_reset = 1'b1;
        repeat (10) @(posedge system_clock);
        system_reset = 1'b0;
        repeat (10) @(posedge system_clock);
        
        while (!left_ready) @(posedge system_clock);
        pcm_data = 24'haaaaaa;
        left_valid = 1;
        while (left_ready) @(posedge system_clock);
        left_valid = 0;

        while (!right_ready) @(posedge system_clock);
        pcm_data = 24'hcdcdcd;
        right_valid = 1;
        while (right_ready) @(posedge system_clock);
        right_valid = 0;
        
    end


endmodule
