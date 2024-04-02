module PC_reg(
    input clk, rst, 
    input [15:0] D, 
    input WriteEnable, 
    output [15:0] q
);

dff ff[15:0](.q(q), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));

endmodule
