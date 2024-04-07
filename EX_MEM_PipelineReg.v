module EX_MEM_PipelineReg(
  input clk, rst,
  input MemWrite, MemRead, MemtoReg, PCS,
  input [15:0] Prev_ALU_Out, DataIn,
  output [15:0] Curr_ALU_Out, WriteData,
  output prop_MemWrite, prop_MemRead, prop_MemtoReg, prop_PCS
);


  dff_16 memaddr_ff(.q(Curr_ALU_Out), .d(Prev_ALU_Out), .clk(clk), .rst(rst), .wen(1'b1));
  dff_16 writedata_ff(.q(WriteData), .d(DataIn), .clk(clk), .rst(rst), .wen(1'b1));

  dff memwrite_ff(.q(prop_MemWrite), .d(MemWrite), .clk(clk), .rst(rst), .wen(1'b1));
  dff memread_ff(.q(prop_MemRead), .d(MemRead), .clk(clk), .rst(rst), .wen(1'b1));
  dff memtoreg_ff(.q(prop_MemtoReg), .d(MemtoReg), .clk(clk), .rst(rst), .wen(1'b1));
  dff pcs_ff(.q(prop_PCS), .d(PCS), .clk(clk), .rst(rst), .wen(1'b1));

endmodule

