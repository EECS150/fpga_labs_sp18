`timescale 1ns/100ps

`define CLK_PERIOD 10
`define SHIFT_REGISTER_DEPTH 5
`define SHIFT_REGISTER_WIDTH 4
`define SHIFT_REGISTER_PRODUCT `SHIFT_REGISTER_WIDTH*`SHIFT_REGISTER_DEPTH

module shift_register_testbench();
    // Generate 100 MHz clock.
    reg clk = 0;
    always #(`CLK_PERIOD/2) clk = ~clk;

    // I/O of shift register.
    reg [`SHIFT_REGISTER_WIDTH-1:0] signal_in;
    reg shift_pulse;
    wire [`SHIFT_REGISTER_PRODUCT-1:0] signal_out;

    shift_register #(
        .DEPTH(`SHIFT_REGISTER_DEPTH),
        .WIDTH(`SHIFT_REGISTER_WIDTH)
    ) DUT (
        .in(signal_in),
        .shift(shift_pulse),
        .out(signal_out)
    );

    initial begin
        shift_pulse = 0;
        // Set initial state, wait for 1 clock cycle
        signal_in = 0;
        @(posedge clk);

        fork
            begin:SIGNAL_THREAD
                integer i;
                for (i = 8; i < 13; i = i + 1) begin
                    @(posedge clk);
                    signal_in = i;
                    shift_pulse = 1'b1;
                    @(posedge clk) shift_pulse = 1'b0;
                    repeat (3) @(posedge clk);
                end
            end

            // You should be getting used to this 2-thread pattern by now
            begin
                @(negedge shift_pulse)
                if (signal_out != 'h8) begin
                    $display("Failure 1: Value should be 0x8 but is %h", signal_out);
                end
                @(negedge shift_pulse)
                if (signal_out != 'h89) begin
                    $display("Failure 2: Value should be 0x89 but is %h", signal_out);
                end
                @(negedge shift_pulse)
                if (signal_out != 'h89a) begin
                    $display("Failure 3: Value should be 0x89a but is %h", signal_out);
                end
                @(negedge shift_pulse)
                if (signal_out != 'h89ab) begin
                    $display("Failure 4: Value should be 0x89ab but is %h", signal_out);
                end
                @(negedge shift_pulse)
                if (signal_out != 'h89abc) begin
                    $display("Failure 5: Value should be 0x89abc but is %h", signal_out);
                end
            end
        join
        $display("Test Done! If any failures were printed, fix them! Otherwise this testbench passed.");
        $finish();
    end
endmodule
