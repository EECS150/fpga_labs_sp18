module piano_fsm (
    input clk,  // 125 MHz clock as usual
    input rst,
    input rotary_event,
    input rotary_left,

    output [7:0] ua_transmit_din,
    output ua_transmit_wr_en,
    input ua_transmit_full,

    input [7:0] ua_receive_dout,
    input ua_receive_empty,
    output ua_receive_rd_en,

    output [19:0] i2s_din,
    output i2s_wr_en,
    input i2s_full,

    output audio_pwm
);
    assign audio_pwm = 1'b0;
    assign ua_transmit_din = 0;
    assign ua_transmit_wr_en = 0;
    assign ua_receive_rd_en = 0;
    assign ac97_din = 0;
    assign ac97_wr_en = 0;
endmodule
