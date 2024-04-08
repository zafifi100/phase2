module cpu(
    input clk, rst_n,
    output hlt, 
    output [15:0] pc
);

//////////////////////////////////////////////////////// Instruction Fetch /////////////////////////////////////////////////////////
// Signals
wire [15:0] curr_pc, next_pc, branch_addr, PC_out, ntaken, instr;
wire enable_stall;
wire [15:0] IF_PC, IF_instr; 

assign next_pc = (B) ? PC_out : ntaken;
assign branch_addr = (BR) ? ReadData1 : next_pc;
assign pc = curr_pc;

// PC REG
PC_reg pcReg(.clk(clk), .rst(~rst_n), .D(branch_addr), .WriteEnable(~HLT), .q(curr_pc));

// MEM FETCH
memory1c fetch(.data_out(instr), .data_in(16'h0000), .addr(curr_pc), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(~rst_n));
assign Opcode = instr[15:12];

//PC inc
add ntakenadd(.Sum(ntaken), .Ovfl(ov), .A(curr_pc), .B(16'h0002), .sub(1'b0));

// FLAG REG
flag_register flag_reg(.clk(clk), .rst(~rst_n), .en(~Opcode[3]), .D(flags), .q(ccc));

// IF/ID Pipeline
IF_ID_PipelineReg ifidpipeline(.clk(clk), .rst(~rst_n), .enable_stall(enable_stall), .pc(ntaken), instr(instr), pc_out(IF_PC), instr_out(IF_instr));



/////////////////////////////////////////////////////// Instruction Decode ///////////////////////////////////////////////////////
// Signals
wire ReadIn, WriteReg, PCS, MemtoReg, MemRead, MemWrite, B, BR, HLT, Error;
wire [1:0] AluSrc1, AluSrc2;
wire [2:0] AluOp;
wire [3:0] ReadRegister1, ReadRegister2, DstReg;
wire [3:0] Opcode;
wire [2:0] ccc;
///////
wire ID_ReadIn, ID_WriteReg, ID_PCS, ID_MemtoReg, ID_MemRead, ID_MemWrite;
wire [1:0] ID_AluSrc1, ID_AluSrc2;
wire [3:0] ID_AluOp;
wire [15:0] ID_ReadData1, ID_ReadData2, ID_Instruction;


assign Opcode = IF_instr[15:12];
control control1(.Opcode(Opcode), .ReadIn(ReadIn), .WriteReg(WriteReg), .PCS(PCS), .AluSrc1(AluSrc1), .AluSrc2(AluSrc2), .MemtoReg(MemtoReg), .MemRead(MemRead), .MemWrite(MemWrite), .B(B), .BR(BR), .HLT(HLT), .AluOp(AluOp), .Error(Error));

assign ReadRegister1 = (ReadIn | MemWrite | MemRead) ? IF_instr[11:8] : IF_instr[7:4];
assign ReadRegister2 = (MemRead | MemWrite) ? IF_instr[7:4] : IF_instr[3:0];
assign DstReg = IF_instr[11:8];

RegisterFile regfile(.clk(clk), .rst(~rst_n), .SrcReg1(ReadRegister1), .SrcReg2(ReadRegister2), .DstReg(DstReg), .WriteReg(WriteReg), .DstData(DstData), .SrcData1(ReadData1), .SrcData2(ReadData2));


hazarddetection hazarddect(.ID_EX_MemRead(ID_MemRead), .IF_ID_MemWrite(MemWrite), .ID_EX_RegisterRd(ID_Instruction[11:8]), .IF_ID_RegisterRs((ReadIn) ? ID_Instruction[11:8] : ID_Instruction[7:4]), .IF_ID_RegisterRt((MemWrite) ? ID_Instruction[11:8] : ID_Instruction[3:0]), .enable_stall(enable_stall));


//PC CONTROL
PC_control pc_log(.C(instr[11:9]), .I(instr[8:0]), .F(ccc), .PC_in(curr_pc), .PC_out(PC_out));


ID_EX_PipelineReg idexpipeline(.clk(clk), .rst(!rst_n), .ReadIn(ReadIn), .WriteReg(WriteReg), .PCS(PCS), .MemtoReg(MemtoReg), .MemRead(MemRead), .MemWrite(MemWrite),
                   .AluSrc1(AluSrc1), .AluSrc2(AluSrc2), AluOp(AluOp), .ReadData1(ReadData1), .ReadData2(ReadData2), .Instruction(IF_instr), 
		           .ReadIn_out(ID_Read_In), .WriteReg_out(ID_WriteReg), .PCS_out(ID_PCS), .MemtoReg_out(ID_MemtoReg), .MemRead_out(ID_MemRead), 
                   .MemWrite_out(ID_MemWrite), .AluSrc1_out(ID_AluSrc1), .AluSrc2_out(ID_AluSrc2),
                   .AluOp_out(ID_AluOp), .ReadData1_out(ID_ReadData1), .ReadData2_out(ID_ReadData2), .Instruction_out(ID_Instruction));


////////////////////////////////////////////Execution Stage////////////////////////////////////////////
wire [15:0] imm_sign;
wire [15:0] address;   
assign imm_sign = {{12{ID_Instruction[3]}}, ID_Instruction[3:0]} << 1;
add add01(.Sum(address), .Ovfl(), .A(ID_ReadData2 & 16'hFFFE), .B(imm_sign), .sub(1'b0));

assign ALU_In1 = (ID_AluSrc1 === 2'b00) ? ID_ReadData1 :
                 (ID_AluSrc1 === 2'b01) ? ID_ReadData1 & 16'hFF00 :  
                 (ID_AluSrc1 === 2'b10) ? ID_ReadData1 & 16'h00FF :
                  ID_ReadData1;
                  
assign ALU_In2 = (ID_AluSrc2 === 2'b00) ? ID_ReadData2 : 
                 (ID_AluSrc2 === 2'b01) ? ID_Instruction[3:0] :
                 (ID_AluSrc2 === 2'b10) ?  address:
                 ((((ID_AluSrc2 === 2'b11) & ID_Read_In & ID_Instruction[12])) ? ID_Instruction[7:0] << 8 : ID_Instruction[7:0]);

assign LHBorLLB = ALU_In1 | ALU_In2;
wire [15:0] temp_alu_out;

ALU alu(.ALU_In1(ALU_In1), .ALU_In2(ALU_In2), .Opcode(ID_AluOp), .ALU_Out(temp_alu_out), .flags(flags));

assign AluOut = (ReadIn) ? LHBorLLB : temp_alu_out;

module EX_MEM_PipelineReg(.clk(clk), .rst(~rst_n), .MemWrite(), .MemRead(), .MemtoReg(), 
                           .PCS(), .Prev_ALU_Out(), DataIn(), Curr_ALU_Out(), WriteData(), prop_MemWrite(), 
                           .prop_MemRead(), .prop_MemtoReg(), .prop_PCS());





































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
