`timescale 1ns/100ps

`define SECOND 1000000000
`define MS 1000000
`define SYSTEM_CLK_PERIOD 8

module i2s_controller_testbench();
    // System clock domain I/O
    reg system_clock = 0;
    reg system_reset = 0;
    
    wire mclk, sclk, lrck, sdin;

    // Generate system clock
    always #(`SYSTEM_CLK_PERIOD/2) system_clock = ~system_clock;

    i2s_controller #(
      .SYS_CLOCK_FREQ(125_000_000),
      .LRCK_FREQ_HZ(88_200),
      .MCLK_TO_LRCK_RATIO(128)
    ) i2s (
      .sys_reset(system_reset),
      .sys_clk(system_clock),
      .mclk(mclk),
      .sclk(sclk),
      .lrck(lrck),
      .sdin(sdin)
    );

    initial begin
        // Pulse the system reset to the i2s controller
        @(posedge system_clock);
        system_reset = 1'b1;
        repeat (10) @(posedge system_clock);
        system_reset = 1'b0;
    end
endmodule
