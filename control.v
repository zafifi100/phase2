module control(Opcode,ReadIn, WriteReg, PCS, AluSrc1, AluSrc2, MemtoReg, MemRead, MemWrite, B, BR, HLT, AluOp, Error);
input [3:0] Opcode;
output reg ReadIn, WriteReg, PCS, MemtoReg, MemRead, MemWrite, B, BR, HLT, Error;
output reg [1:0] AluSrc1, AluSrc2;
output reg [2:0] AluOp;

always @(*) begin
    ReadIn = 1'b0;
    WriteReg = 1'b0;
    PCS = 1'b0;
    MemtoReg = 1'b0;
    MemRead = 1'b0;
    MemWrite = 1'b0;
    B = 1'b0;
    BR = 1'b0;
    HLT = 1'b0;
    Error = 1'b0;
    AluSrc1 = 2'b00;
    AluSrc2 = 2'b00;
    AluOp = 3'b000;

    case(Opcode)
        4'b0000: begin     //ADD(Rtype)
            WriteReg = 1'b1;
        end 
        4'b0001: begin      //SUB(Rtype)
            WriteReg = 1'b1;
            AluOp = Opcode[2:0];
        end 
        4'b0010: begin      //XOR(Rtype)
            WriteReg = 1'b1;
            AluOp = Opcode[2:0];
        end 
        4'b0011: begin    //RED(Rtype)
            WriteReg = 1'b1;
            AluOp = Opcode[2:0];
        end 
        4'b0100: begin   //SLL(IType)
            WriteReg = 1'b1;
            AluOp = Opcode[2:0];
            AluSrc2 = 2'b01;
        end
        4'b0101: begin //SRA(IType)
            WriteReg = 1'b1;
            AluOp = Opcode[2:0];
            AluSrc2 = 2'b01;
        end
        4'b0110: begin //ROR(IType)
            WriteReg = 1'b1;
            AluOp = Opcode[2:0];
            AluSrc2 = 2'b01;
        end
        4'b0111: begin   //PADDSB(Rtype)
            WriteReg = 1'b1;
            AluOp = Opcode[2:0];
        end 
        4'b1000: begin   ///LW
            WriteReg = 1'b1;
            AluSrc1 = 2'b11;
            AluSrc2 = 2'b10;
            MemRead = 1'b1;
            MemtoReg = 1'b1;  
        end
        4'b1001: begin     ///SW
            AluSrc1 = 2'b11;
            AluSrc2 = 2'b10;
            MemWrite = 1'b1;
        end
        4'b1010: begin    //LLB
            ReadIn = 1'b1;
            WriteReg = 1'b1;
            AluSrc1 = 2'b01;
            AluSrc2 = 2'b11;
        end 
        4'b1011: begin ///LHB
            ReadIn = 1'b1;
            WriteReg = 1'b1;
            AluSrc1 = 2'b10;
            AluSrc2 = 2'b11;
        end 
        4'b1100: begin //B
            B = 1'b1;
        end
        4'b1101: begin //BR
            BR =1'b1;
        end
        4'b1110: begin //PCS
            WriteReg = 1'b1;
            PCS = 1'b1;
        end 
        4'b1111: begin //HLT
            HLT = 1'b1;
        end
        default: begin
            Error = 1'b1;
        end 
    endcase
end

endmodule
