module add (Sum, Ovfl, A, B, sub);

  input [15:0] A, B;
  input sub; 
  output [15:0] Sum; 
  output Ovfl;

  wire [15:0] FA_sum;
  wire FA1_cout, FA2_cout, FA3_cout, FA4_cout, FA5_cout, FA6_cout, FA7_cout, FA8_cout, FA9_cout, FA10_cout, FA11_cout, FA12_cout, FA13_cout, FA14_cout, FA15_cout;

  full_adder_1bit FA1(.A(A[0]), .B((sub) ? ~ B[0] : B[0]), .cin(sub ? 1'b1 : 1'b0), .cout(FA1_cout), .sum(FA_sum[0]));
  full_adder_1bit FA2(.A(A[1]), .B((sub) ? ~ B[1] : B[1]), .cin(FA1_cout), .cout(FA2_cout), .sum(FA_sum[1]));
  full_adder_1bit FA3(.A(A[2]), .B((sub) ? ~ B[2] : B[2]), .cin(FA2_cout), .cout(FA3_cout), .sum(FA_sum[2]));
  full_adder_1bit FA4(.A(A[3]), .B((sub) ? ~ B[3] : B[3]), .cin(FA3_cout), .cout(FA4_cout), .sum(FA_sum[3]));
  full_adder_1bit FA5(.A(A[4]), .B((sub) ? ~ B[4] : B[4]), .cin(FA4_cout), .cout(FA5_cout), .sum(FA_sum[4]));
  full_adder_1bit FA6(.A(A[5]), .B((sub) ? ~ B[5] : B[5]), .cin(FA5_cout), .cout(FA6_cout), .sum(FA_sum[5]));
  full_adder_1bit FA7(.A(A[6]), .B((sub) ? ~ B[6] : B[6]), .cin(FA6_cout), .cout(FA7_cout), .sum(FA_sum[6]));
  full_adder_1bit FA8(.A(A[7]), .B((sub) ? ~ B[7] : B[7]), .cin(FA7_cout), .cout(FA8_cout), .sum(FA_sum[7]));
  full_adder_1bit FA9(.A(A[8]), .B((sub) ? ~ B[8] : B[8]), .cin(FA8_cout), .cout(FA9_cout), .sum(FA_sum[8]));
  full_adder_1bit FA10(.A(A[9]), .B((sub) ? ~ B[9] : B[9]), .cin(FA9_cout), .cout(FA10_cout), .sum(FA_sum[9]));
  full_adder_1bit FA11(.A(A[10]), .B((sub) ? ~ B[10] : B[10]), .cin(FA10_cout), .cout(FA11_cout), .sum(FA_sum[10]));
  full_adder_1bit FA12(.A(A[11]), .B((sub) ? ~ B[11] : B[11]), .cin(FA11_cout), .cout(FA12_cout), .sum(FA_sum[11]));
  full_adder_1bit FA13(.A(A[12]), .B((sub) ? ~ B[12] : B[12]), .cin(FA12_cout), .cout(FA13_cout), .sum(FA_sum[12]));
  full_adder_1bit FA14(.A(A[13]), .B((sub) ? ~ B[13] : B[13]), .cin(FA13_cout), .cout(FA14_cout), .sum(FA_sum[13]));
  full_adder_1bit FA15(.A(A[14]), .B((sub) ? ~ B[14] : B[14]), .cin(FA14_cout), .cout(FA15_cout), .sum(FA_sum[14]));
  full_adder_1bit FA16(.A(A[15]), .B((sub) ? ~ B[15] : B[15]), .cin(FA15_cout), .cout(FA16_cout), .sum(FA_sum[15]));


  assign Sum[15:0] = FA_sum[15:0];

  assign Ovfl = (A[15] === B[15]) &&  (A[15] !== FA_sum[15]);

endmodule


