`timescale 1ns/100ps

`define SECOND 1000000000
`define MS 1000000

// Only 1 of these defines should be uncommented at a time!
`define SYNC_FIFO_TEST
//`define ASYNC_FIFO_TEST

// Clock periods for the read and write clocks
// If performing the synchronous FIFO test, the read clock will be used for both the read/write interfaces
`define RD_CLK_PERIOD 30
`define WR_CLK_PERIOD 80

`define DATA_WIDTH 32
`define FIFO_DEPTH 8

module fifo_testbench();
    reg rd_clk = 0;
    reg wr_clk = 0;
    reg rst = 0;

    always #(`RD_CLK_PERIOD/2) rd_clk = ~rd_clk;
    `ifdef SYNC_FIFO_TEST
        always @ (*) wr_clk = rd_clk;
    `endif
    `ifdef ASYNC_FIFO_TEST
        always #(`WR_CLK_PERIOD/2) wr_clk = ~wr_clk;
    `endif

    // Write side signals
    reg [`DATA_WIDTH-1:0] din = 0;
    reg wr_en = 0;
    wire full;

    // Read side signals
    wire [`DATA_WIDTH-1:0] dout;
    reg rd_en = 0;
    wire empty;

    // Reg filled with test vectors for the testbench
    reg [`DATA_WIDTH-1:0] test_values[`FIFO_DEPTH-1:0];
    // Reg used to collect the data read from the FIFO
    reg [`DATA_WIDTH-1:0] received_values[`FIFO_DEPTH-1:0];

    `ifdef SYNC_FIFO_TEST
    // Instantiate the DUT
    fifo #(
        .data_width(`DATA_WIDTH),
        .fifo_depth(`FIFO_DEPTH)
    ) DUT (
        .clk(rd_clk),
        .rst(rst),
        .wr_en(wr_en),
        .din(din),
        .full(full),
        .rd_en(rd_en),
        .dout(dout),
        .empty(empty)
    );
    `endif

    `ifdef ASYNC_FIFO_TEST
    async_fifo #(
        .data_width(`DATA_WIDTH),
        .fifo_depth(`FIFO_DEPTH)
    ) DUT (
        .rd_clk(rd_clk),
        .wr_clk(wr_clk),
        .wr_en(wr_en),
        .din(din),
        .full(full),
        .rd_en(rd_en),
        .dout(dout),
        .empty(empty)
    );
    `endif

    // This task will push some data to the FIFO through the write interface
    // If violate_interface == 1'b1, we will force wr_en high even if the FIFO indicates it is full
    // If violate_interface == 1'b0, we won't write if the FIFO indicates it is full
    task write_to_fifo;
        input [`DATA_WIDTH-1:0] write_data;
        input violate_interface;
        begin
            // If we want to not violate the interface agreement, if we are already full, don't write
            if (!violate_interface && full) begin
                wr_en <= 1'b0;
            end
            // In all other cases, we will force a write
            else begin
                wr_en <= 1'b1;
            end

            // Apply the data input
            din <= write_data;

            // Wait for the clock edge to perform the write
            @(posedge wr_clk);
            #1;

            // Deassert the write enable
            wr_en <= 1'b0;
        end
    endtask

    // This task will read some data from the FIFO through the read interface
    // violate_interface does the same as for the write_to_fifo task
    task read_from_fifo;
        input violate_interface;
        output [`DATA_WIDTH-1:0] read_data;
        begin
            if (!violate_interface && empty) begin
                rd_en <= 1'b0;
            end
            else begin
                rd_en <= 1'b1;
            end
            // Wait for the clock edge to get the read data
            @(posedge rd_clk);
            #1;

            read_data = dout;
            rd_en <= 1'b0;
        end
    endtask

    initial begin: TB
        integer i;
        // Generate the random data to write to the FIFO
        for (i = 0; i < `FIFO_DEPTH; i = i + 1) begin
            test_values[i] <= $urandom();
        end

        rst <= 1'b1;
        @(posedge rd_clk);
        rst <= 1'b0;
        @(posedge rd_clk);

        // Let's begin with a simple complete write and read sequence to the FIFO

        // Check initial conditions, verify that the FIFO is not full, it is empty
        if (empty !== 1'b1) begin
            $display("After reset, the FIFO isn't empty. empty = %b", empty);
            $finish();
        end

        if (full !== 1'b0) begin
            $display("After reset, the FIFO is full. full = %b", full);
            $finish();
        end

        @(posedge wr_clk);

        // Begin pushing data into the FIFO with a 1 cycle delay in between each write operation
        for (i = 0; i < `FIFO_DEPTH - 1; i = i + 1) begin
            write_to_fifo(test_values[i], 1'b0);

            // Perform checks on empty, full (disable check on empty for async FIFO due to synchronization delay)
            `ifdef SYNC_FIFO_TEST
                if (empty === 1'b1) begin
                    $display("FIFO was empty as it's being filled"); $finish();
                end
            `endif
            if (full === 1'b1) begin
                $display("FIFO was full before all entries have been filled"); $finish();
            end

            // Insert single-cycle delay between each write
            @(posedge wr_clk);
        end

        // Perform the final write
        write_to_fifo(test_values[`FIFO_DEPTH-1], 1'b0);

        // Check that the FIFO is now full
        if (full !== 1'b1 || empty === 1'b1) begin
            $display("FIFO wasn't full or empty went high.\n");
            $display("full = %b, empty = %b", full, empty);
            $finish();
        end

        // Cycle the clock, the FIFO should still be full!
        repeat (10) @(posedge wr_clk);
        // The FIFO should still be full!
        if (full !== 1'b1 || empty == 1'b1) begin
            $display("Cycling the clock while the FIFO is full shouldn't change its stage! \n");
            $display("full = %b, empty = %b", full, empty);
            $finish();
        end

        // Try stuffing the FIFO with more data while it's full (overflow protection check)
        repeat (20) begin
            write_to_fifo(0, 1'b1);
            // Check that the FIFO is still full, has the max num of entries, and isn't empty
            if (full !== 1'b1 || empty == 1'b1) begin
                $display("Overflowing the FIFO changed its stage (your FIFO should have overflow protection) \n");
                $display("full = %b, empty = %b", full, empty);
                $finish();
            end
        end

        repeat (5) @(posedge rd_clk);

        // Read from the FIFO one by one with a 1 cycle delay in between reads
        for (i = 0; i < `FIFO_DEPTH - 1; i = i + 1) begin
            read_from_fifo(1'b0, received_values[i]);

            // Perform checks on empty, full (disable full check for async fifo due to synchronization delay)
            if (empty === 1'b1) begin
                $display("FIFO was empty as it's being filled"); $finish();
            end
            `ifdef SYNC_FIFO_TEST
                if (full === 1'b1) begin
                    $display("FIFO was full before all entries have been filled"); $finish();
                end
            `endif

            @(posedge rd_clk);
        end

        // Perform the final read
        read_from_fifo(1'b0, received_values[`FIFO_DEPTH-1]);
        // Check that the FIFO is now empty
        if (full !== 1'b0 || empty !== 1'b1) begin
            $display("FIFO wasn't empty or full went high.\n");
            $display("full = %b, empty = %b", full, empty);
            $finish();
        end

        // Cycle the clock and perform the same checks
        repeat (10) @(posedge rd_clk);
        if (full !== 1'b0 || empty !== 1'b1) begin
            $display("FIFO wasn't empty or full went high.\n");
            $display("full = %b, empty = %b", full, empty);
            $finish();
        end

        // Finally, let's check that the data we received from the FIFO equals the data that we wrote to it
        for (i = 0; i < `FIFO_DEPTH; i = i + 1) begin
            if (test_values[i] !== received_values[i]) begin
                $display("Data received from FIFO not equal to data written.");
                $display("Entry %d, got %d, expected %d", i, received_values[i], test_values[i]);
            end
        end

        // Now attempt a read underflow
        repeat (10) read_from_fifo(1'b1, received_values[0]);
        // Nothing should change, perform the same checks on full and empty
        if (full !== 1'b0 || empty !== 1'b1) begin
            $display("FIFO wasn't empty or full went high.\n");
            $display("full = %b, empty = %b", full, empty);
            $finish();
        end

        // SUCCESS! Print out some debug info.
        $display("ALL FIFO TESTS PASSED!\n");
        $display("This testbench was run with these params:\n");
        `ifdef SYNC_FIFO_TEST
            $display("Testbench for synchronous FIFO (shared read/write clock, using read clock period)");
        `endif
        `ifdef ASYNC_FIFO_TEST
            $display("Testbench for asynchronous FIFO (separate read/write clock)");
        `endif
        $display("RD_CLK_PERIOD = %d, WR_CLK_PERIOD = %d, DATA_WIDTH = %d, FIFO_DEPTH = %d", `RD_CLK_PERIOD, `WR_CLK_PERIOD, `DATA_WIDTH, `FIFO_DEPTH);
        $finish();
    end
endmodule
