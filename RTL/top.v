`timescale 1ns / 1ps

module top #(
    parameter WIDTH  = 256,
    parameter HEIGHT = 256
)(
    input  wire       clk,
    input  wire       rst,
    output wire [7:0] edge_out,
    output reg        done
);

    localparam IMAGE_SIZE = WIDTH * HEIGHT;

    // INTERCONNECTS
    // Expanded to 17 bits so it can safely hold the value 65536
    reg  [16:0] addr; 
    wire [7:0]  current_pixel;
    
    // 3x3 Window Registers
    reg [7:0] p00, p01, p02;
    reg [7:0] p10, p11, p12;
    reg [7:0] p20, p21, p22;

    // Line Buffers
    reg [7:0] line_buf_0 [0:WIDTH-1];
    reg [7:0] line_buf_1 [0:WIDTH-1];
    
    // Buffer read/write pointer
    reg [16:0] buf_ptr; 

    //--------------------------------------------------
    // 1. Instantiate Image Loader
    //--------------------------------------------------
    image_loader #(
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT)
    ) img_loader_inst (
        .clk(clk),
        .rst(rst),
        .addr(addr[15:0]), // Truncate safely to the loader's expected 16 bits
        .pixel(current_pixel)
    );

    //--------------------------------------------------
    // 2. Address Generation Control
    //--------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            addr    <= 17'd0;
            buf_ptr <= 17'd0;
            done    <= 1'b0;
        end else if (addr < IMAGE_SIZE) begin
            addr    <= addr + 1'b1;
            // Align buffer pointer with the image stream
            if (addr >= 1) begin
                buf_ptr <= (buf_ptr == WIDTH - 1) ? 17'd0 : buf_ptr + 1'b1;
            end
        end else begin
            done    <= 1'b1; 
        end
    end

    //--------------------------------------------------
    // 3. Line Buffers & 3x3 Sliding Window Logic
    //--------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            p00 <= 8'd0; p01 <= 8'd0; p02 <= 8'd0;
            p10 <= 8'd0; p11 <= 8'd0; p12 <= 8'd0;
            p20 <= 8'd0; p21 <= 8'd0; p22 <= 8'd0;
        end else begin
            // Shift columns left
            p00 <= p01; p01 <= p02;
            p10 <= p11; p11 <= p12;
            p20 <= p21; p21 <= p22;

            // Fetch sequential rows from line memories safely
            p02 <= line_buf_0[buf_ptr]; 
            p12 <= line_buf_1[buf_ptr];
            p22 <= current_pixel;

            // Shift rows vertically into memories
            line_buf_0[buf_ptr] <= line_buf_1[buf_ptr];
            line_buf_1[buf_ptr] <= current_pixel;
        end
    end

    //--------------------------------------------------
    // 4. Instantiate Sobel Filter
    //--------------------------------------------------
    sobel_filter filter_inst (
        .clk(clk),
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .edge_out(edge_out)
    );

endmodule