`timescale 1ns/100ps

`define SECOND 1000000000
`define MS 1000000
`define SYSTEM_CLK_PERIOD 8

module system_testbench();
    // System clock domain I/O
    reg system_clock = 0;
    reg system_reset = 0;
    wire mclk, sclk, lrck, sdin, audio_pwm;
    wire [5:0] leds;
    wire [7:0] pmod_leds;

    reg [2:0] buttons;
    reg [1:0] switches;

    // Generate system clock
    always #(`SYSTEM_CLK_PERIOD/2) system_clock = ~system_clock;

    z1top z1_default_params (
      .RESET(system_reset),
      .CLK_125MHZ_FPGA(system_clock),
      .BUTTONS(buttons),
      .SWITCHES(switches),
      .LEDS(leds),
      .PMOD_LEDS(leds),
      .MCLK(mclk),
      .LRCLK(lrck),
      .SCLK(sclk),
      .SDIN(sdin),
      .AUDIO_PWM(audio_pwm)
    );
    
    // Instantiate an off-chip UART here that uses the RX and TX lines
    // You can refer to the echo_testbench from lab 4

    initial begin
        // Enable mono audio out and audio controller output.
        switches[0] = 1'b1;
        switches[1] = 1'b1;

        // Simulate pushing the RESET button and holding it for a while
        // Verify that the reset signal into the i2s controller only pulses once
        system_reset = 1'b0;
        repeat (10) @(posedge system_clock);
        system_reset = 1'b1;
        repeat (10) @(posedge system_clock);

        // Send a few characters through the off_chip_uart

        // Watch your Piano FSM at work
        #(`MS * 20);

        // ADD SOME MORE STUFF HERE TO TEST YOUR PIANO FSM
        $finish();
    end


endmodule
