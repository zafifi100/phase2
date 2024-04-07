module dff_16 (
    input clk, rst, wen,
    input [15:0] d,
    output [15:0] q
);

dff ff[15:0](.q(q), .d(d), .wen(wen), .clk(clk), .rst(rst));
    
endmodule