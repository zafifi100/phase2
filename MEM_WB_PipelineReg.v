module EX_MEM_PipelineReg(
  input clk, rst,
  input MemtoReg,
  input [15:0] Prev_read_data,
  output [15:0] Curr_read_data,
  output prop_MemtoReg
);

  dff_16 readdata_ff(.q(Curr_read_data), .d(Prev_read_data), .clk(clk), .rst(rst), .wen(1'b1));

  dff memtoreg_ff(.q(prop_MemtoReg), .d(MemtoReg), .clk(clk), .rst(rst), .wen(1'b1));

endmodule

