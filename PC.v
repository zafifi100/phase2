
module PC_control(
    input [2:0] C,
    input [8:0] I,
    input [2:0] F,
    input [15:0] PC_in,
    output [15:0] PC_out
);

    reg [15:0] target;
    wire [15:0] imm_shift;
    wire [15:0] taken, ntaken;

    assign imm_shift = {{7{I[8]}},I[8:0]} << 1;

    add ntakenadd(.A(PC_in), .B(16'h0002), .Sum(ntaken), .Ovfl(ovfl_n), .sub(1'b0));
    add takenadd(.A(ntaken), .B(imm_shift), .Sum(taken), .Ovfl(ovfl_t), .sub(1'b0));

    always @(*) begin
        case(C)
            3'b000: target = (F[1]) ? taken : ntaken; // Not Equal (Z = 0)
            3'b001: target = (F[1]) ? taken : ntaken; // Equal (Z = 1)
            3'b010: target = ((F[2]) & (F[1])) ? taken : ntaken; // Greater Than (Z = N = 0)
            3'b011: target = (F[2]) ? taken : ntaken; // Less Than (N = 1)
            3'b100: target = (F[1] | ~F[2] | ~F[1]) ? taken : ntaken; // Greater Than or Equal (Z = 1 or Z = N = 0)
            3'b101: target = ((F[2]) | (F[1])) ? taken : ntaken; // Less Than or Equal (N = 1 or Z = 1)
            3'b110: target = (F[0]) ? taken : ntaken; // Overflow (V = 1)
            3'b111: target = taken; // Unconditional
            default: target = ntaken;
        endcase
    end

    assign PC_out = target;

endmodule

