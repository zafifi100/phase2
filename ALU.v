module ALU(
    input [15:0] ALU_In1, ALU_In2,
    input [2:0] Opcode,
    output [15:0] ALU_Out,
    output [2:0] flags
);

    wire [15:0] xor_out, red_out, add_out, sub_out, sra_out, sll_out, ror_out, paddsb_out;
    wire add_ovfl, sub_ovfl;

    /// ADD
    cla_16bit  add(.A(ALU_In1), .B(ALU_In2), .cin(1'b0), .sub(1'b0), .Sum(add_out), .Ovfl(add_ovfl));
 
    /// SUB
    cla_16bit  sub(.A(ALU_In1), .B(ALU_In2), .cin(1'b1), .sub(1'b1), .Sum(sub_out), .Ovfl(sub_ovfl));

    /// SRA
    sra shift_right(.Shift_Out(sra_out), .Shift_In(ALU_In1), .Shift_Val(ALU_In2[3:0]));

    /// SLL
    sll shift_left(.Shift_Out(sll_out), .Shift_In(ALU_In1), .Shift_Val(ALU_In2[3:0]));

    /// RED
    red_16bit reduce(.A(ALU_In1), .B(ALU_In2), .Output(red_out));

    /// XOR
    xor_16bit res(.A(ALU_In1), .B(ALU_In2), .Output(xor_out));

    /// ROR
    ROR rotate(.rotate_val(ALU_In1), .amt(ALU_In2[3:0]), .data_out(ror_out));

    /// PADDSB
    paddsb_16bit paddsb(.Sum(paddsb_out), .A(ALU_In1), .B(ALU_In2));



    assign ALU_Out = (Opcode === 3'b000) ? (add_out) : 
                     (Opcode === 3'b001) ? (sub_out) :
                     (Opcode === 3'b010) ? (xor_out) :
		     (Opcode === 3'b011) ? (red_out) :
                     (Opcode === 3'b100) ? (sll_out) :
                     (Opcode === 3'b101) ? (sra_out) :
                     (Opcode === 3'b110) ? (ror_out) :
                     (Opcode === 3'b111) ? (paddsb_out):
                      16'h0000;

   // V flag
   assign flags[0] = ((Opcode === 4'b0000) && (add_ovfl === 1'b1)) ? 1'b1:
		     ((Opcode === 4'b0001) && (sub_ovfl === 1'b1)) ? 1'b1: 
          	      1'b0;

   // Z flag
   assign flags[1] = (ALU_Out === 16'h0000);

   // N flag
   assign flags[2] = ((Opcode === 4'b0000) && (add_out[15] === 1'b1)) ? 1'b1:
		     ((Opcode === 4'b0001) && (sub_out[15] === 1'b1)) ? 1'b1: 
                      1'b0;

endmodule
