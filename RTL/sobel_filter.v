`timescale 1ns / 1ps

module sobel_filter(
    input clk,

    input [7:0] p00, p01, p02,
    input [7:0] p10, p11, p12,
    input [7:0] p20, p21, p22,

    output reg [7:0] edge_out
);

    // Signed values because Sobel gradients can be negative
    reg signed [11:0] gx;
    reg signed [11:0] gy;

    reg [11:0] abs_gx;
    reg [11:0] abs_gy;
    reg [12:0] magnitude;

    always @(posedge clk)
    begin

        // Horizontal Gradient
        gx <=
            $signed({1'b0,p02}) + ($signed({1'b0,p12}) <<< 1) + $signed({1'b0,p22})
          - $signed({1'b0,p00}) - ($signed({1'b0,p10}) <<< 1) - $signed({1'b0,p20});

        // Vertical Gradient
        gy <=
            $signed({1'b0,p00}) + ($signed({1'b0,p01}) <<< 1) + $signed({1'b0,p02})
          - $signed({1'b0,p20}) - ($signed({1'b0,p21}) <<< 1) - $signed({1'b0,p22});

        // Absolute values
        abs_gx <= (gx < 0) ? -gx : gx;
        abs_gy <= (gy < 0) ? -gy : gy;

        // Gradient Magnitude
        magnitude <= abs_gx + abs_gy;

        // Saturation
        if (magnitude > 255)
            edge_out <= 8'd255;
        else
            edge_out <= magnitude[7:0];

    end

endmodule