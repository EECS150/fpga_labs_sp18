`timescale 1ns/1ns

`define SECOND 1000000000
`define MS 1000000
`define SAMPLE_PERIOD 22675.7

module music_streamer_testbench();
    reg clock;
    wire speaker;

    initial clock = 0;
    always #(8/2) clock <= ~clock;

    z1top top (
        .CLK_125MHZ_FPGA(clock),
        .BUTTONS(4'hF),
        .SWITCHES(2'b11),
        .LEDS(),
        .AUDIO_PWM(speaker)
    );

    initial begin
        #(2 * `SECOND);
        $finish();
    end

    integer file;
    initial begin
        file = $fopen("output.txt", "w");
        forever begin
            $fwrite(file, "%h\n", speaker);
            #(`SAMPLE_PERIOD);
        end
    end

endmodule
