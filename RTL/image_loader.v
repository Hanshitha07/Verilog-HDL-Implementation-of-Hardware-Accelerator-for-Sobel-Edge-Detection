`timescale 1ns / 1ps

module image_loader
#(
    parameter WIDTH  = 256,
    parameter HEIGHT = 256
)
(
    input  wire clk,
    input  wire rst,
    input  wire [15:0] addr,
    output reg  [7:0] pixel
);

localparam IMAGE_SIZE = WIDTH * HEIGHT;

//--------------------------------------------------
// Image Memory
//--------------------------------------------------
reg [7:0] image_mem [0:IMAGE_SIZE-1];

//--------------------------------------------------
// Load Image
//--------------------------------------------------
initial
begin
    $display("--------------------------------");
    $display("Loading input.mem...");
    $readmemh("input.mem", image_mem);
    $display("Image Loaded Successfully.");
    $display("--------------------------------");
end

//--------------------------------------------------
// Output Pixel
//--------------------------------------------------
always @(posedge clk)
begin
    if (rst)
        pixel <= 8'd0;
    else if (addr < IMAGE_SIZE)
        pixel <= image_mem[addr];
    else
        pixel <= 8'd0;
end

endmodule