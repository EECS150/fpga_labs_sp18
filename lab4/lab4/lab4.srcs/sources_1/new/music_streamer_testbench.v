`timescale 1ns/1ns

`define SECOND 1000000000
`define MS 1000000
`define SAMPLE_PERIOD 22675.7

module music_streamer_testbench();
    // Global signals
    reg clock;
    reg reset;

    // Music streamer inputs
    reg tempo_up;
    reg tempo_down;
    reg tempo_reset;
    reg play_pause;
    reg switch_fn;
    reg switch_mode;
    reg edit_next_node;
    reg edit_prev_node;

    initial begin
      tempo_up = 0;
      tempo_down = 0;
      tempo_reset = 0;
      play_pause = 0;
      switch_fn = 0;
      switch_mode = 0;
      edit_next_node = 0;
      edit_prev_node = 0;
    end

    // Music streamer outputs
    wire [23:0] tone_to_play;
    wire led_paused;
    wire led_regular_play;
    wire led_reverse_play;
    wire led_play_seq;
    wire led_edit_seq;

    // Tone generator input
    reg output_enable;

    // Tone generator output
    wire sq_wave;

    initial clock = 0;
    always #(8/2) clock <= ~clock;

    tone_generator audio_controller (
        .clk(clock),
        .rst(reset),
        .output_enable(output_enable),
        .tone_switch_period(tone_to_play),
        .square_wave_out(sq_wave)
    );

    music_streamer streamer (
        .clk(clock),
        .rst(reset),
        .tempo_up(tempo_up),
        .tempo_down(temp_down),
        .tempo_reset(tempo_reset),
        .play_pause(play_pause),
        .switch_fn(switch_fn),
        .switch_mode(switch_mode),
        .edit_next_node(edit_next_node),
        .edit_prev_node(edit_prev_node),
        .led_paused(led_paused),
        .led_regular_play(led_regular_play),
        .led_reverse_play(led_reverse_play),
        .led_play_seq(led_play_seq),
        .led_edit_seq(led_edit_seq),
        .tone(tone_to_play)
    );

    initial begin
        reset = 0;
        // Reset our modules and enable the tone_generator output
        @(posedge clock);
        reset = 1;
        @(posedge clock);
        reset = 0;
        output_enable = 1;

        // Warning: do not exceed delays of 2 seconds at a time
        // otherwise the delay won't work properly with our simulator
        #(2 * `SECOND);

        // Get FSM into PAUSED state by simulating center button press
        @(posedge clock);
        play_pause = 1'b1;
        @(posedge clock);
        play_pause = 1'b0;
        #(300 * `MS);

        // Get FSM into REGULAR_PLAY, then REVERSE_PLAY state
        @(posedge clock);
        play_pause = 1'b1;
        @(posedge clock);
        play_pause = 1'b0;
        @(posedge clock);
        switch_mode = 1'b1;
        @(posedge clock);
        switch_mode = 1'b0;
        #(300 * `MS);

        // Simulate tempo adjustment by clicking wheel left 10 times
        repeat (10) begin
            @(posedge clock);
            tempo_up = 1'b1;
            @(posedge clock);
            tempo_up = 1'b0;
        end

        // Move to the REGULAR_PLAY state with tempo adjusted and see how music sounds
        @(posedge clock);
        switch_mode = 1'b1;
        @(posedge clock);
        switch_mode = 1'b0;
        #(1 * `SECOND);

        $finish();
    end

    integer file;
    initial begin
        file = $fopen("output.txt", "w");
        forever begin
            $fwrite(file, "%h\n", sq_wave);
            #(`SAMPLE_PERIOD);
        end
    end

endmodule
