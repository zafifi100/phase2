module IF_ID_PipelineReg (
    input clk, rst, enable_stall, Flush
    input [15:0] pc, instr,
    output [15:0] pc_out, instr_out
);

  dff_16 pc_ff(.q(pc_out), .d(pc), .clk(clk), .rst(rst), .wen(enable_stall));
  dff_16 instrr(.q((!Flush) ? instr_out : 16'h4000), .d(instr), .rst(rst), .wen(enable_stall));

endmodule