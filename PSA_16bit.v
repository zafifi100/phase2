module PSA_16bit (Sum, Error, A, B);
  input [15:0] A, B;   
  output [15:0] Sum;   
  output Error;        

  wire [3:0] FA_sum_0, FA_sum_1, FA_sum_2, FA_sum_3;
  wire Ovfl_0, Ovfl_1, Ovfl_2, Ovfl_3;

  addsub FA0(.A(A[3:0]), .B(B[3:0]), .sub(1'b0), .Sum(FA_sum_0), .Ovfl(Ovfl_0));
  addsub FA1(.A(A[7:4]), .B(B[7:4]), .sub(1'b0), .Sum(FA_sum_1), .Ovfl(Ovfl_1));
  addsub FA2(.A(A[11:8]), .B(B[11:8]), .sub(1'b0), .Sum(FA_sum_2), .Ovfl(Ovfl_2));
  addsub FA3(.A(A[15:12]), .B(B[15:12]), .sub(1'b0), .Sum(FA_sum_3), .Ovfl(Ovfl_3));

  assign Sum = {FA_sum_3, FA_sum_2, FA_sum_1, FA_sum_0};

  assign Error = (Ovfl_0 | Ovfl_1 | Ovfl_2 | Ovfl_3);

endmodule

