`timescale 1ns / 1ps

module top_tb; // Matches your filename top_tb.v

    // Parameters matching our design
    parameter WIDTH  = 256;
    parameter HEIGHT = 256;
    localparam TOTAL_PIXELS = WIDTH * HEIGHT;

    // Inputs to UUT (Unit Under Test)
    reg clk;
    reg rst;

    // Outputs from UUT
    wire [7:0] edge_out;
    wire done;

    // File handling variables for simulation verification
    integer out_file;
    integer pixel_count;

    //--------------------------------------------------
    // 1. Instantiate the Unit Under Test (UUT)
    //--------------------------------------------------
    top #(
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT)
    ) uut (
        .clk(clk),
        .rst(rst),
        .edge_out(edge_out),
        .done(done)
    );

    //--------------------------------------------------
    // 2. Clock Generation (50 MHz -> 20ns period)
    //--------------------------------------------------
    always begin
        #10 clk = ~clk;
    end

    //--------------------------------------------------
    // 3. Main Simulation Control
    //--------------------------------------------------
    initial begin
        // Initialize inputs
        clk = 0;
        rst = 1;
        pixel_count = 0;

        // Open a file to save the processed output image
        out_file = $fopen("output.mem", "w");
        if (out_file == 0) begin
            $display("[ERROR] Could not create output.mem file!");
            $finish;
        end

        $display("[TB] Resetting system...");
        #100; // Hold reset for 100ns
        rst = 0;
        
        $display("[TB] Simulation Started. Processing image pixels...");

        // Wait until the top module asserts the 'done' signal
        wait(done == 1'b1);
        
        // Give it a couple extra cycles to let the last pipeline stages empty out
        #40;

        $display("[TB] Simulation Finished. Total pixels captured: %d", pixel_count);
        $fclose(out_file);
        $finish;
    end

    //--------------------------------------------------
    // 4. Capture Output Stream and Log to File
    //--------------------------------------------------
    always @(posedge clk) begin
        if (!rst && !done) begin
            // Start logging once valid data begins escaping the pipeline buffer delay
            if (uut.addr > (WIDTH * 2 + 2)) begin
                $fdisplay(out_file, "%h", edge_out);
                pixel_count = pixel_count + 1;
            end
        end
    end

endmodule