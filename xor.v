//Xor 16bit module.
module xor_16bit(A, B, Output);
input [15:0] A;
input [15:0] B;
output [15:0] Output;

assign Output = A ^ B;
endmodule