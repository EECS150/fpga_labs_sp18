module tone_generator (
    input output_enable,
    input [23:0] tone_switch_period,
    input clk,
    output square_wave_out
);
    assign square_wave_out = 1'b0;
endmodule
