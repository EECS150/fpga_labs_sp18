module music_streamer (
    input clk,
    input rst,
    input tempo_up,
    input tempo_down,
    input tempo_reset,
    input play_pause,           // Switches between play and pause
    input switch_fn,            // Switches between regular play and play sequence
    input switch_mode,          // Switches between forward and reverse or play and edit sequence
    input edit_next_node,       // Select next tone to edit
    input edit_prev_node,       // Selects previous tone to edi
    output led_paused,
    output led_regular_play,
    output led_reverse_play,
    output led_play_seq,
    output led_edit_seq,
    output [23:0] tone
);
    reg [9:0] tone_index;
    reg [22:0] clock_counter;
    rom music_data (
        .address(tone_index),       // 10 bits
        .data(tone),                // 24 bits
        .last_address()
    );

    initial begin
      tone_index = 0;
      clock_counter = 0;
    end

    // YOUR CODE FROM LAB3 HERE - you may have to modify this template to integrate your old code.

    // Remove these assignments after creating the FSM
    assign led_paused = 1'b1;
    assign led_regular_play = 1'b0;
    assign led_reverse_play = 1'b0;
    assign led_play_seq = 1'b0;
    assign led_edit_seq = 1'b0;

    // Use these nets for constructing your FSM
    localparam PAUSED = 3'd0;
    localparam REGULAR_PLAY = 3'd1;
    localparam REVERSE_PLAY = 3'd2;
    localparam PLAY_SEQ = 3'd3;
    localparam EDIT_SEQ = 3'd4;
    reg [2:0] current_state;
    reg [2:0] next_state;

    // The following RTL is provided as starter code for Section 8: Music Sequencer
    reg [23:0] sequencer_mem [7:0];
    reg [2:0] sequencer_addr;
    reg [23:0] tone_under_edit;

    // Registering and modification of the tone_under_edit (sequencer)
    always @ (posedge clk) begin
        tone_under_edit <= tone_under_edit;

        // If we are moving into edit mode from the play mode, register the note
        if (next_state == EDIT_SEQ && current_state == PLAY_SEQ) begin
            tone_under_edit <= sequencer_mem[sequencer_addr];
        end
        // We are currently in edit mode, if we switch notes or edit the current note, we should update the tone_under_edit
        else if (current_state == EDIT_SEQ) begin
            if (edit_next_node) tone_under_edit <= sequencer_mem[sequencer_addr + 3'd1];
            else if (edit_prev_node) tone_under_edit <= sequencer_mem[sequencer_addr - 3'd1];
            else tone_under_edit <= tone_under_edit;
        end
    end

    // Modification of the sequencer notes (sequencer_mem)
    always @ (posedge clk) begin
        if (rst) begin
            sequencer_mem[0] <= 24'd37500;
            sequencer_mem[1] <= 24'd37500;
            sequencer_mem[2] <= 24'd37500;
            sequencer_mem[3] <= 24'd37500;
            sequencer_mem[4] <= 24'd37500;
            sequencer_mem[5] <= 24'd37500;
            sequencer_mem[6] <= 24'd37500;
            sequencer_mem[7] <= 24'd37500;
        end
        // If we are in edit mode and the user pushes in tempo_reset, store the tone_under_edit in the sequencer memory, for some reason.
        else if (current_state == EDIT_SEQ && tempo_reset) begin
            sequencer_mem[sequencer_addr] <= tone_under_edit;
        end
        else begin
            sequencer_mem[sequencer_addr] <= sequencer_mem[sequencer_addr];
        end
    end

endmodule
