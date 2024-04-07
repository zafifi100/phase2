module dff_4 (
    input clk, rst, wen,
    input [3:0] d,
    output [3:0] q
);

dff ff[3:0](.q(q), .d(d), .wen(wen), .clk(clk), .rst(rst));

endmodule
