module EX_MEM_PipelineReg(
  input clk, rst,
  input MemtoReg, PCS,
  input [15:0] Prev_MemData,
  input [15:0] Prev_AluOut,
  input [15:0] PC,
  output [15:0] PC_out,
  output [15:0] Curr_Memdata,
  output [15:0] Curr_AluOut,
  output prop_MemtoReg, prop_PCS
);

  dff_16 readdata_ff(.q(Curr_Memdata), .d(Prev_MemData), .clk(clk), .rst(rst), .wen(1'b1));
  dff_16 aluout_ff(.q(Curr_AluOut), .d(Prev_AluOut), .clk(clk), .rst(rst), .wen(1'b1))
  dff memtoreg_ff(.q(prop_MemtoReg), .d(MemtoReg), .clk(clk), .rst(rst), .wen(1'b1));
  dff_16 pc_ff(.q(PC_out), .d(PC), .clk(clk), .rst(rst), .wen(enable_stall));
  dff pcs_ff(.q(prop_PCS), .d(PCS), .clk(clk), .rst(rst), .wen(1'b1));
endmodule

