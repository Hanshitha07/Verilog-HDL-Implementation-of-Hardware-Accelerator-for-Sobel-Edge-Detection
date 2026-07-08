`timescale 1ns / 1ps

module tb_pixel_reader;

reg clk;
reg rst;
reg enable;

wire [7:0] pixel;
wire valid;
wire done;

pixel_reader uut(

    .clk(clk),
    .rst(rst),
    .enable(enable),

    .pixel(pixel),
    .valid(valid),
    .done(done)

);

always #5 clk = ~clk;

initial
begin

    clk = 0;
    rst = 1;
    enable = 0;

    #20;

    rst = 0;
    enable = 1;

    wait(done);

    #20;

    $finish;

end

endmodule