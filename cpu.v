module cpu(
    input clk, rst_n,
    output hlt, 
    output [15:0] pc
);

// Signals
wire [15:0] curr_pc, next_pc, branch_addr, PC_out, ntaken, instr;
wire [2:0] flags;
wire ov;
wire enable_stall;
wire [15:0] IF_PC, IF_instr; 

// Signals
wire ReadIn, WriteReg, PCS, MemtoReg, MemRead, MemWrite, B, BR, HLT, Error, Flush;
wire [1:0] AluSrc1, AluSrc2;
wire [15:0] ALU_In1, ALU_In2;
wire [15:0] LHBorLLB;
wire [15:0] AluOut;
wire [15:0] DstData;
wire [2:0] AluOp;
wire [3:0] ReadRegister1, ReadRegister2, DstReg;
wire [3:0] Opcode;
wire [2:0] ccc;

wire ID_Read_In, ID_WriteReg, ID_PCS, ID_MemtoReg, ID_MemRead, ID_MemWrite, ID_HLT;
wire [1:0] ID_AluSrc1, ID_AluSrc2;
wire [3:0] ID_AluOp;
wire [15:0] ID_ReadData1, ID_ReadData2, ID_Instruction, ID_PC;
wire [15:0] imm_sign;
wire [15:0] address, EX_address;
wire [15:0] EX_ALU_Out, EX_DataIn;
wire [15:0] ReadData1, ReadData2;

wire EX_MemWrite, EX_MemRead, EX_MemtoReg, EX_PCS, EX_WriteReg, EX_HLT;
wire [15:0] EX_PC, EX_Instruction;
wire [15:0] MEM_DataOut;
wire [15:0] MEM_AluOut;
wire [15:0] memDataOut;
wire [15:0] MEM_PC, MEM_Instruction;
wire MEM_MemtoReg, MEM_PCS, MEM_WriteReg, MEM_HLT;

wire [1:0] ForwardA, ForwardB;
wire ForwardMem;

//////////////////////////////////////////////////////// Instruction Fetch /////////////////////////////////////////////////////////
assign next_pc = (B) ? PC_out : ntaken;
assign branch_addr = (BR) ? ReadData1 : next_pc;
assign pc = curr_pc;

// PC REG
PC_reg pcReg(.clk(clk), .rst(~rst_n), .D(branch_addr), .eanble_stall((&instr[15:12] & ~Flush) | enable_stall), .q(curr_pc));

// MEM FETCH
memory1c fetch(.data_out(instr), .data_in(16'h0000), .addr(curr_pc), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(~rst_n));

//PC inc
add ntakenadd(.Sum(ntaken), .Ovfl(ov), .A(curr_pc), .B(16'h0002), .sub(1'b0));

// FLAG REG
flag_register flag_reg(.clk(clk), .rst(~rst_n), .en(~instr[15]), .D(flags), .q(ccc));

// IF/ID Pipeline
IF_ID_PipelineReg ifidpipeline(.clk(clk), .rst(~rst_n), .enable_stall(enable_stall), .pc(ntaken), .instr(instr), .pc_out(IF_PC), .instr_out(IF_instr));



/////////////////////////////////////////////////////// Instruction Decode ///////////////////////////////////////////////////////
control control1(.Opcode(IF_instr[15:12]), .ReadIn(ReadIn), .WriteReg(WriteReg), .PCS(PCS), .AluSrc1(AluSrc1), .AluSrc2(AluSrc2), .MemtoReg(MemtoReg), .MemRead(MemRead), .MemWrite(MemWrite), .B(B), .BR(BR), .HLT(HLT), .AluOp(AluOp), .Error(Error));

assign ReadRegister1 = (ReadIn | MemWrite | MemRead) ? IF_instr[11:8] : IF_instr[7:4]; ////Rs
assign ReadRegister2 = (MemRead | MemWrite) ? IF_instr[7:4] : IF_instr[3:0]; ///Rt
assign DstReg = MEM_Instruction[11:8];

RegisterFile regfile(.clk(clk), .rst(~rst_n), .SrcReg1(ReadRegister1), .SrcReg2(ReadRegister2), .DstReg(DstReg), .WriteReg(MEM_WriteReg), .DstData(DstData), .SrcData1(ReadData1), .SrcData2(ReadData2));


hazarddetection hazarddect(.ID_EX_MemRead(ID_MemRead), .IF_ID_MemWrite(MemWrite), .ID_EX_RegisterRd(ID_Instruction[11:8]), .IF_ID_RegisterRs((ReadIn) ? ID_Instruction[11:8] : ID_Instruction[7:4]), .IF_ID_RegisterRt((MemWrite) ? ID_Instruction[11:8] : ID_Instruction[3:0]), .enable_stall(enable_stall));


//PC CONTROL
PC_control pc_log(.C(instr[11:9]), .I(instr[8:0]), .F(ccc), .PC_in(IF_PC), .PC_out(PC_out), .Flush(Flush));


ID_EX_PipelineReg idexpipeline(.clk(clk), .rst(!rst_n), .ReadIn(ReadIn), .HLT(HLT),  .WriteReg(WriteReg), .PCS(PCS), .MemtoReg(MemtoReg), .MemRead(MemRead), .MemWrite(MemWrite),
                   .AluSrc1(AluSrc1), .AluSrc2(AluSrc2), .AluOp(AluOp), .ReadData1(ReadData1), .ReadData2(ReadData2), .Instruction(IF_instr), .PC(IF_PC),
		   .ReadIn_out(ID_Read_In), .WriteReg_out(ID_WriteReg), .PCS_out(ID_PCS), .MemtoReg_out(ID_MemtoReg), .MemRead_out(ID_MemRead), 
                   .MemWrite_out(ID_MemWrite), .AluSrc1_out(ID_AluSrc1), .AluSrc2_out(ID_AluSrc2),
                   .AluOp_out(ID_AluOp), .ReadData1_out(ID_ReadData1), .ReadData2_out(ID_ReadData2), .Instruction_out(ID_Instruction), .PC_out(ID_PC), .HLT_out(ID_HLT));


////////////////////////////////////////////Execution Stage////////////////////////////////////////////
wire [15:0] forward_ALU_IN1, forward_ALU_IN2;
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

assign forward_ALU_IN1 = (ForwardA === 2'b10) ? EX_ALU_Out : (ForwardA === 2'b01) ? DstData : ALU_In1;
assign forward_ALU_IN2 = (ForwardB === 2'b10) ? EX_ALU_Out : (ForwardB === 2'b01) ? DstData : ALU_In2;

ALU alu(.ALU_In1(forward_ALU_IN1), .ALU_In2(forward_ALU_IN2), .Opcode(ID_AluOp), .ALU_Out(temp_alu_out), .flags(flags));

assign AluOut = (ID_Read_In) ? LHBorLLB : temp_alu_out;


EX_MEM_PipelineReg exmempipline(.clk(clk), .rst(~rst_n), .MemWrite(ID_MemWrite), .MemRead(ID_MemRead), .MemtoReg(ID_MemtoReg), .HLT(ID_HLT), .Instruction(ID_Instruction), .Address(address), .Address_out(EX_address)
                           .PCS(ID_PCS), .PC(ID_PC), .WriteReg(ID_WriteReg), .Prev_ALU_Out(AluOut), .DataIn(ID_ReadData1), .Curr_ALU_Out(EX_ALU_Out), .WriteData(EX_DataIn), .prop_MemWrite(EX_MemWrite), 
                           .prop_MemRead(EX_MemRead), .prop_MemtoReg(EX_MemtoReg), .prop_PCS(EX_PCS), .PC_out(EX_PC), .WriteReg_Out(EX_WriteReg), .HLT_Out(EX_HLT), .Instruction_out(EX_Instruction));



////////////////////////////////////////////Memory Stage////////////////////////////////////////////
wire [15:0] forward_Mem_Data = (ForwardMem) ? DstData : EX_DataIn;
memory1c mem(.data_out(memDataOut), .data_in(forward_Mem_Data), .addr(EX_address), .enable(EX_MemRead | EX_MemWrite), .wr(EX_MemWrite), .clk(clk), .rst(~rst_n));

MEM_WB_PipelineReg memwbpipeline(.clk(clk), .rst(~rst_n), .PCS(EX_PCS), .MemtoReg(EX_MemtoReg), .Prev_MemData(memDataOut), .PC(EX_PC), .HLT(EX_HLT), .Instruction(EX_Instruction),
                                .Prev_AluOut(EX_ALU_Out), .WriteReg(EX_WriteReg), .Curr_Memdata(MEM_DataOut), .Curr_AluOut(MEM_AluOut), 
                                .prop_MemtoReg(MEM_MemtoReg), .prop_PCS(MEM_PCS), .PC_out(MEM_PC), .WriteReg_Out(MEM_WriteReg), .HLT_Out(MEM_HLT), .Instruction_out(MEM_Instruction));

/////////////////////////////////WriteBack/////////////////////////////////////
assign DstData = (MEM_PCS) ? MEM_PC : 
                 (MEM_MemtoReg) ? MEM_DataOut : 
                  MEM_AluOut;


assign hlt = MEM_HLT;

///////////////Fowarding Unit////////////////////////////////////////////////
forwardunit fu(.EX_MEM_Regwrite(EX_WriteReg), .MEM_WB_Regwrite(MEM_WriteReg), .EX_MEM_RegisterRd(EX_Instruction[11:8]), .ID_EX_RegisterRs((ID_Read_In) ? ID_Instruction[11:8] : ID_Instruction[7:4]),  
               .ID_EX_RegisterRt((ID_MemWrite) ? ID_Instruction[11:8] : ID_Instruction[3:0]), .MEM_WB_RegisterRd(MEM_Instruction[11:8]), .EX_MEM_RegisterRt((EX_MemWrite) ? EX_Instruction[11:8] : EX_Instruction[3:0]),
               .ForwardA(ForwardA), .ForwardB(ForwardB), .ForwardMem(ForwardMem));



endmodule

