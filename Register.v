module Register( 
    input clk, 
    input rst, 
    input [15:0] D, 
    input WriteEnable, ReadEnable1, ReadEnable2, 
    inout [15:0] Bitline1, Bitline2
);

    BitCell cells[15:0](.clk(clk), .rst(rst), .D(D), .WriteEnable(WriteEnable), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1), .Bitline2(Bitline2));


endmodule
