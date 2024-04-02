module RegisterFile(
    input clk, 
    input rst, 
    input [3:0] SrcReg1, SrcReg2, DstReg, 
    input WriteReg, 
    input [15:0] DstData, 
    inout [15:0] SrcData1, SrcData2
);

    wire [15:0] Wordline1, Wordline2, Wordline3;
    wire [15:0] SrcData1Int, SrcData2Int;

    ReadDecoder_4_16 dec1(.RegId(SrcReg1), .Wordline(Wordline1));
    ReadDecoder_4_16 dec2(.RegId(SrcReg2), .Wordline(Wordline2));
    WriteDecoder_4_16 write1(.RegId(DstReg), .WriteReg(WriteReg), .Wordline(Wordline3));


    Register regfile[15:0](.clk(clk), .rst(rst), .D(DstData), .WriteEnable(Wordline3), .ReadEnable1(Wordline1), .ReadEnable2(Wordline2), .Bitline1(SrcData1Int), .Bitline2(SrcData2Int));
    
    //assign SrcData1 = ((DstReg === SrcReg1) & WriteReg) ? DstData : SrcData1Int;    
    //assign SrcData2 = ((DstReg === SrcReg2) & WriteReg) ? DstData : SrcData2Int;  
    assign SrcData1 = SrcData1Int;    
    assign SrcData2 = SrcData2Int;
endmodule
