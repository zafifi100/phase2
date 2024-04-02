module cpu(
    input clk, rst_n,
    output hlt, 
    output [15:0] pc
);

////////////////////// Instuction Fetch Stage Signals ///////////////////////
wire [15:0] curr_pc, next_pc, branch_addr, PC_out, ntaken, instr;

////////////////////////////////////// Decode Stage Signals /////////////////////////////////////////
wire ReadIn, WriteReg, PCS, MemtoReg, MemRead, MemWrite, B, BR, HLT, Error;
wire [1:0] AluSrc1, AluSrc2;
wire [2:0] AluOp;
wire [3:0] ReadRegister1, ReadRegister2, DstReg;
wire [3:0] Opcode;
wire [2:0] ccc;

////////////////////// Execution Signals ///////////////////////
wire [15:0] AluOut, ALU_In1, ALU_In2;
wire [15:0] LHBorLLB;
wire [2:0] flags;

////////////////////// Execution Signals ///////////////////////
wire [15:0] DstData, ReadData1, ReadData2;

//////////////////Memory Signals///////////////////////////////
wire [15:0] mem_out;


//////////////////////////////////////////// Fetch Instruction Stage ////////////////////////////////////////////////////////

// PC CONTROL
PC_control pc_log(.C(instr[11:9]), .I(instr[8:0]), .F(ccc), .PC_in(curr_pc), .PC_out(PC_out));

// PC REG
PC_reg pcReg(.clk(clk), .rst(~rst_n), .D(branch_addr), .WriteEnable(~HLT), .q(curr_pc));

// MEM FETCH
memory1c fetch(.data_out(instr), .data_in(16'h0000), .addr(curr_pc), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(~rst_n));
assign Opcode = instr[15:12];

// FLAG REG
flag_register flag_reg(.clk(clk), .rst(~rst_n), .en(~Opcode[3]), .D(flags), .q(ccc));





/////////////////////////////////////////////////////////////// Decode Stage /////////////////////////////////////////////////////////////////////////////////
control control1(.Opcode(Opcode), .ReadIn(ReadIn), .WriteReg(WriteReg), .PCS(PCS), .AluSrc1(AluSrc1), .AluSrc2(AluSrc2), .MemtoReg(MemtoReg), .MemRead(MemRead), .MemWrite(MemWrite), .B(B), .BR(BR), .HLT(HLT), .AluOp(AluOp), .Error(Error));

assign ReadRegister1 = (ReadIn | MemWrite | MemRead) ? instr[11:8] : instr[7:4];
assign ReadRegister2 = (MemRead | MemWrite) ? instr[7:4] : instr[3:0];
assign DstReg = instr[11:8];

RegisterFile regfile(.clk(clk), .rst(~rst_n), .SrcReg1(ReadRegister1), .SrcReg2(ReadRegister2), .DstReg(DstReg), .WriteReg(WriteReg), .DstData(DstData), .SrcData1(ReadData1), .SrcData2(ReadData2));





//////////////////////////////////////// Execute Stage (ALU) ///////////////////////////////////////////////
wire [15:0] imm_sign;
wire [15:0] address;   
assign imm_sign = {{12{instr[3]}}, instr[3:0]} << 1;
add add01(.Sum(address), .Ovfl(), .A(ReadData2 & 16'hFFFE), .B(imm_sign), .sub(1'b0));

assign ALU_In1 = (AluSrc1 === 2'b00) ? ReadData1 :
                 (AluSrc1 === 2'b01) ? ReadData1 & 16'hFF00 :  
                 (AluSrc1 === 2'b10) ? ReadData1 & 16'h00FF :
                  ReadData1;
                  
assign ALU_In2 = (AluSrc2 === 2'b00) ? ReadData2 : 
                 (AluSrc2 === 2'b01) ? instr[3:0] :
                 (AluSrc2 === 2'b10) ?  address:
                 ((((AluSrc2 === 2'b11) & ReadIn & Opcode[0])) ? instr[7:0] << 8 : instr[7:0]);

assign LHBorLLB = ALU_In1 | ALU_In2;
wire [15:0] temp_alu_out;

ALU alu(.ALU_In1(ALU_In1), .ALU_In2(ALU_In2), .Opcode(AluOp), .ALU_Out(temp_alu_out), .flags(flags));

assign AluOut = (ReadIn) ? LHBorLLB : temp_alu_out;



//////////////////////////////////////////////////// Memory ////////////////////////////////////////////////////////////
memory1c mem(.data_out(mem_out), .data_in(ReadData1), .addr(address), .enable(MemRead | MemWrite), .wr(MemWrite), .clk(clk), .rst(~rst_n));

assign DstData = (PCS) ? next_pc : 
                 (MemtoReg) ? mem_out : 
                  AluOut;

add ntakenadd(.Sum(ntaken), .Ovfl(ov), .A(curr_pc), .B(16'h0002), .sub(1'b0));

assign next_pc = (B) ? PC_out : ntaken;
assign branch_addr = (BR) ? ReadData1 : next_pc;
assign hlt = HLT;
assign pc = curr_pc;

endmodule
