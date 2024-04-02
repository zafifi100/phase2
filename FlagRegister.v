module flag_register(
    input clk, rst, en,  
    input [2:0] D, 
    output [2:0] q
);

    dff ff[2:0](.clk(clk), .rst(rst), .wen(en), .d(D), .q(q));

endmodule
