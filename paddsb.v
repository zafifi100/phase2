//full adder module
module full_adder_1bit(A, B, cin, Sum, cout);
	input A, B, cin;
	output Sum, cout;

	assign Sum = A ^ B ^ cin;
	assign cout = (A & B) | (A & cin) | (B & cin);
endmodule

//non CLA implementation of addsub 4bit 
module addsub_4bit(Sum, Ovfl, A, B, sub);
	input [3:0] A, B;
	input sub;
	output [3:0] Sum;
	output Ovfl;
	
	wire [3:1] carry;
	wire [3:0] B_invert;
	wire carry_in, carry_out;

	assign B_invert = sub ? ~B : B;
	assign carry_in = sub;
	
	
	full_adder_1bit FA1 (.A(A[0]), .B(B_invert[0]), .cin(carry_in), .sum(Sum[0]), .cout(carry[1]));
	full_adder_1bit FA2 (.A(A[1]), .B(B_invert[1]), .cin(carry[1]), .sum(Sum[1]), .cout(carry[2]));
	full_adder_1bit FA3 (.A(A[2]), .B(B_invert[2]), .cin(carry[2]), .sum(Sum[2]), .cout(carry[3]));
	full_adder_1bit FA4 (.A(A[3]), .B(B_invert[3]), .cin(carry[3]), .sum(Sum[3]), .cout(carry_out));
	
	assign Ovfl = carry_out ^ carry[3];
endmodule

//pasddsb_16bit module
module paddsb_16bit(Sum, A, B);
input [15:0] A, B;
output [15:0] Sum; 	

wire [3:0] Ovfl;
wire [15:0] temp_sum;
wire [3:0] sum1, sum2, sum3, sum4;

addsub_4bit ADDER1 (.A(A[3:0]), .B(B[3:0]), .Sum(temp_sum[3:0]), .Ovfl(Ovfl[0]), .sub(1'b0));
assign sum1 = (A[3] & B[3] & ~temp_sum[3]) ? 4'h8 : 
              (~A[3] & ~B[3] & temp_sum[3]) ? 4'h7 :
	      temp_sum[3:0]; 

addsub_4bit ADDER2 (.A(A[7:4]), .B(B[7:4]), .Sum(temp_sum[7:4]), .Ovfl(Ovfl[1]), .sub(1'b0));
assign sum2 = (A[7] & B[7] & ~temp_sum[7]) ? 4'h8 : 
              (~A[7] & ~B[7] & temp_sum[7]) ? 4'h7 :
	      temp_sum[7:4]; 


addsub_4bit ADDER3 (.A(A[11:8]), .B(B[11:8]), .Sum(temp_sum[11:8]), .Ovfl(Ovfl[2]), .sub(1'b0));
assign sum3 = (A[11] & B[11] & ~temp_sum[11]) ? 4'h8 : 
              (~A[11] &~ B[11] & temp_sum[11]) ? 4'h7 :
	      temp_sum[11:8]; 


addsub_4bit ADDER4 (.A(A[15:12]), .B(B[15:12]), .Sum(temp_sum[15:12]), .Ovfl(Ovfl[3]), .sub(1'b0));
assign sum4 = (A[15] & B[15] & ~temp_sum[15]) ? 4'h8 : 
              (~A[15] &~ B[15] & temp_sum[15]) ? 4'h7 :
	      temp_sum[15:12]; 


assign Sum = {sum4, sum3, sum2, sum1};

endmodule