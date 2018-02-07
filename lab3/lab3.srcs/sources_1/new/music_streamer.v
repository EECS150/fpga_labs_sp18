module music_streamer (
    input clk,
    output [23:0] tone,
    output [9:0] rom_address
);
    assign tone = 24'd0;
    assign rom_address = 10'd0;
endmodule
