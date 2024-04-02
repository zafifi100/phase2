module WriteDecoder_4_16(input [3:0] RegId, input WriteReg, output [15:0] Wordline);

    wire [15:0] line;

    ReadDecoder_4_16 dec(RegId, line);

    assign Wordline = (WriteReg === 1'b1) ? line: 16'h0000;

endmodule
